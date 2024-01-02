import Foundation

let contents = try! String(contentsOfFile: "input.txt")
let map = contents.split(separator: "\n").map(Array.init)
let width = map[0].count
let height = map.count

var startPos = SIMD2<Int>()
outerLoop: for y in 0..<height {
    for x in 0..<width {
        if map[y][x] == "S" {
            startPos = .init(x, y)
            break outerLoop
        }
    }
}

let connections: Dictionary<Character, [SIMD2<Int>]> = [
    "|": [.init(0, -1), .init(0, 1)], 
    "-": [.init(-1, 0), .init(1, 0)],
    "L": [.init(0, -1), .init(1, 0)],
    "J": [.init(0, -1), .init(-1, 0)],
    "7": [.init(0, 1), .init(-1, 0)],
    "F": [.init(0, 1), .init(1, 0)]]

let adjacent: [SIMD2<Int>] = [.init(0, -1), .init(-1, 0), .init(1, 0), .init(0, 1)]

var nextPos = SIMD2<Int>()
for offset in adjacent {
    let neighbor = startPos &+ offset
    if neighbor.x >= 0, neighbor.y >= 0, neighbor.x < width, neighbor.y < height,
            let offsets = connections[map[neighbor.y][neighbor.x]],
            offsets.contains(offset &* -1) {
        nextPos = neighbor
        break
    }
}

var filled = Array(repeating: Array(repeating: false, count: width), count: height)
filled[startPos.y][startPos.x] = true

func cross(_ a: SIMD2<Int>, _ b: SIMD2<Int>) -> Int {
    a.x * b.y - a.y * b.x
}

var pos = nextPos
var prevPos = startPos
var rights = 0
var counter = 1
while true {
    let lastOffset = prevPos &- pos
    let ch = map[pos.y][pos.x]
    filled[pos.y][pos.x] = true
    if ch == "S" {
        break
    }
    for offset in connections[ch]! {
        if offset != lastOffset {
            prevPos = pos
            pos = pos &+ offset
            rights += cross(lastOffset, offset)
            break
        }
    }
}

var fillCount = 0

func fill(_ pos: SIMD2<Int>) {
    if pos.x < 0 || pos.y < 0 || pos.x >= width || pos.y >= height || filled[pos.y][pos.x] {
        return
    }
    filled[pos.y][pos.x] = true
    fillCount += 1
    fill(.init(pos.x, pos.y - 1))
    fill(.init(pos.x - 1, pos.y))
    fill(.init(pos.x + 1, pos.y))
    fill(.init(pos.x, pos.y + 1))
}

func sign(_ value: Int) -> Int {
    value > 0 ? 1 : value < 0 ? -1 : 0
}

pos = nextPos
prevPos = startPos
while true {
    let lastOffset = prevPos &- pos
    let ch = map[pos.y][pos.x]
    if ch == "S" {
        break
    }
    for offset in connections[ch]! {
        if offset != lastOffset {
            for delta in adjacent {
                if sign(cross(delta, offset)) == sign(rights) || sign(cross(delta, lastOffset)) == -sign(rights) {
                    fill(pos &+ delta)
                }
            }
            prevPos = pos
            pos = pos &+ offset
            break
        }
    }
}

print(fillCount)