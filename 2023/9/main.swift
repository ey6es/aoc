import Foundation

let contents = try! String(contentsOfFile: "input.txt")
let sequences = contents.split(separator: "\n").map { line in
    line.split(separator: " ").map { Int($0)! }
}

func getPrevious(_ sequence: [Int]) -> Int {
    var diffs = Array(repeating: 0, count: sequence.count - 1)
    var allZero = true
    for i in 0..<sequence.count - 1 {
        let diff = sequence[i + 1] - sequence[i]
        if diff != 0 {
            allZero = false
        }
        diffs[i] = diff
    }
    return sequence.first! - (allZero ? 0 : getPrevious(diffs))
}

let sum = sequences.map(getPrevious).reduce(0, +)

print(sum)