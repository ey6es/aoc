import Foundation

let contents = try! String(contentsOfFile: "input.txt")

let sum = contents.split(separator: "\n").map { line in
    let sides = line.split(separator: ":")
    let sets = sides[1].split(separator: ";")
    var maxCounts = [0, 0, 0]
    sets.forEach { set in
        set.split(separator: ",").forEach { element in
            let parts = element.split(separator: " ")
            let index = switch parts[1] {
                case "red": 0
                case "green": 1
                default: 2 
            }
            maxCounts[index] = max(maxCounts[index], Int(parts[0])!)
        }
    }
    return maxCounts.reduce(1, *)
}.reduce(0, +)

print(sum)
