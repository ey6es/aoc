import Foundation

struct Hand {
    let bid: Int
    let value: Int
}

let values = Array("J23456789TQKA")

let contents = try! String(contentsOfFile: "input.txt")
var hands = contents.split(separator: "\n").map { line in
    let parts = line.split(separator: " ")
    let contents = parts[0]
    var counts: Dictionary<Character, Int> = ["A": 0]
    var jokers = 0
    contents.forEach {
        if $0 == "J" {
            jokers += 1
        } else {
            counts[$0, default: 0] += 1
        }
    }
    var sorted = counts.values.sorted(by: >)
    sorted[0] += jokers
    var value = switch sorted[0] {
        case 5: 6
        case 4: 5
        case 3: switch sorted[1] {
            case 2: 4
            default: 3
        }
        case 2: switch sorted[1] {
            case 2: 2
            default: 1
        }
        default: 0
    }
    for ch in contents {
        value = value * 13 + values.firstIndex(of: ch)!
    }
    return Hand(bid: Int(parts[1])!, value: value)
}

hands.sort { $0.value < $1.value }

let total = hands.enumerated().map { (i, hand) in
    (i + 1) * hand.bid
}.reduce(0, +)

print(total)
