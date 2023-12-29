import Foundation

let contents = try! String(contentsOfFile: "input.txt")
let lines = contents.split(separator: "\n")

let seedValues = lines[0].split(separator: " ")[1...].map { Int($0)! }
var seedRanges: [Range<Int>] = []
for i in stride(from: 0, to: seedValues.count, by: 2) {
    let start = seedValues[i]
    seedRanges.append((start..<start + seedValues[i + 1]))
}

struct Map {
    let range: Range<Int>
    let offset: Int
}

let steps = contents.split(separator: "\n\n")[1...].map { section in
    section.split(separator: "\n")[1...].map { line in
        let parts = line.split(separator: " ").map { Int($0)! }
        let start = parts[1]
        return Map(range: (start..<start + parts[2]), offset: parts[0] - start)
    }
}

var lowest = Int.max

func filter(_ range: Range<Int>, _ level: Int) {
    if level == steps.count {
        lowest = min(lowest, range.lowerBound)
        return
    }
    var remainingRanges = [range]
    for map in steps[level] {
        let lowerBound = max(range.lowerBound, map.range.lowerBound)
        let upperBound = min(range.upperBound, map.range.upperBound)
        if upperBound > lowerBound {
            filter((lowerBound + map.offset..<upperBound + map.offset), level + 1)

            let removeRange = (lowerBound..<upperBound)
            remainingRanges = remainingRanges.flatMap { range in
                if !range.overlaps(removeRange) {
                    return [range]
                }
                var ranges: [Range<Int>] = []
                if removeRange.lowerBound > range.lowerBound {
                    ranges.append((range.lowerBound..<removeRange.lowerBound))
                }
                if removeRange.upperBound < range.upperBound {
                    ranges.append((removeRange.upperBound..<range.upperBound))
                }
                return ranges
            }
        }
    }
    for range in remainingRanges {
        filter(range, level + 1)
    }
}

for range in seedRanges {
    filter(range, 0)
}

print(lowest)