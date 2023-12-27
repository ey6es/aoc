import Foundation

let contents = try! String(contentsOfFile: "input.txt")

let lines = contents.split(separator: "\n")
let chars = lines.map(Array.init)
let width = chars.first!.count

let numberPattern = #/\d+/#

var gearParts: Dictionary<SIMD2<Int>, [Int]> = [:]

func mapGearPart(_ x: Int, _ y: Int, _ part: Int) {
    if x >= 0 && x < width && y >= 0 && y < lines.count && chars[y][x] == "*" {
        gearParts[.init(x, y), default: []].append(part)
    }
}

func mapGearPart(_ xMin: Int, _ xMax: Int, _ y: Int, _ part: Int) {
    mapGearPart(xMin - 1, y, part)
    mapGearPart(xMax, y, part)
    for x in (xMin - 1)...xMax {
        mapGearPart(x, y - 1, part)
        mapGearPart(x, y + 1, part)
    }
}

for y in 0..<lines.count {
    let line = lines[y]
    let lineStart = line.startIndex.utf16Offset(in: line)
    for match in line.matches(of: numberPattern) {
        let xMin = match.range.lowerBound.utf16Offset(in: line) - lineStart
        let xMax = match.range.upperBound.utf16Offset(in: line) - lineStart
        mapGearPart(xMin, xMax, y, Int(match.output)!)
    }
}

var total = 0

for parts in gearParts.values {
    if parts.count == 2 {
        total += parts[0] * parts[1]
    }
}

print(total)