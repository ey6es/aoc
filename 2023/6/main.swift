import Foundation

let contents = try! String(contentsOfFile: "input.txt")
let lines = contents.split(separator: "\n")
let time = Double(lines[0].split(separator: " ")[1...].joined())!
let distance = Double(lines[1].split(separator: " ")[1...].joined())! + 1

let left = Int(ceil((time - sqrt(time * time - 4 * distance)) / 2))
let right = Int(floor((time + sqrt(time * time - 4 * distance)) / 2))

print(right - left + 1)



