import Foundation

let contents = try! String(contentsOfFile: "input.txt")

let scores = contents.split(separator: "\n").map { line in
    let sides = line.split(separator: ":")[1].split(separator: "|")
    let winning = Set(sides[0].split(separator: " ").map { Int($0) })
    let have = Set(sides[1].split(separator: " ").map { Int($0) })
    return winning.intersection(have).count
}

var counts = Array(repeating: 1, count: scores.count)

for i in 0..<scores.count {
    let count = counts[i]
    for j in 0..<scores[i] {
        let index = i + j + 1
        if index < scores.count {
            counts[index] += count
        }
    }
}

print(counts.reduce(0, +))