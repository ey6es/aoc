import Foundation

let digits = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

let contents = try! String(contentsOfFile: "input.txt")

let sum = contents.split(separator: "\n").map { line in
    var firstValue: Int?
    var firstIndex = line.endIndex
    var lastValue: Int?
    var lastIndex = line.startIndex
    for digit in 1...9 {
        for string in [digit.description, digits[digit - 1]] {
            if let firstRange = line.range(of: string), firstRange.lowerBound < firstIndex {
                firstValue = digit
                firstIndex = firstRange.lowerBound
            }
            if let lastRange = line.range(of: string, options: [.backwards]), lastRange.lowerBound >= lastIndex {
                lastValue = digit
                lastIndex = lastRange.lowerBound
            }
        }
    }
    return firstValue! * 10 + lastValue!
}.reduce(0, +)

print(sum)