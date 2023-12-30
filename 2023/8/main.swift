import Foundation

let contents = try! String(contentsOfFile: "input.txt")
let lines = contents.split(separator: "\n")
let path = lines[0]

let pattern = #/^(\w\w\w) = \((\w\w\w), (\w\w\w)\)$/#

struct Node {
    let left: Substring
    let right: Substring
}

var nodes: Dictionary<Substring, Node> = [:]
var starters: [Substring] = []

for line in lines[1...] {
    let match = try! pattern.firstMatch(in: line)!
    nodes[match.1] = .init(left: match.2, right: match.3)
    if match.1.last == "A" {
        starters.append(match.1)
    }
}

let periods = starters.map {
    var current = $0
    var steps = 0
    outerLoop: while true {
        for step in path {
            let node = nodes[current]!
            current = switch step {
                case "L": node.left
                default: node.right
            }
            steps += 1
            if current.last == "Z" {
                break outerLoop
            }
        }
    }
    return steps
}

// https://en.wikipedia.org/wiki/Greatest_common_divisor#Euclidean_algorithm
func gcd(_ a: Int, _ b: Int) -> Int {
    b == 0 ? a : gcd(b, a % b)
}

// https://en.wikipedia.org/wiki/Least_common_multiple#Using_the_greatest_common_divisor
func lcm(_ a: Int, _ b: Int) -> Int {
    a * b / gcd(a, b)
}

print(periods.reduce(1, lcm))
