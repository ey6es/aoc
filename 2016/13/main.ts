const input = 1362

function isWall (pos :[number, number]) {
  let [x, y] = pos
  let bits = x*x + 3*x + 2*x*y + y + y*y + input
  let wall = false
  while (bits !== 0) {
    if ((bits & 1) === 1) wall = !wall
    bits >>= 1
  }
  return wall
}

function encodeLocation (pos :[number, number]) {
  return (pos[0] << 16) | pos[1]
}

function decodeLocation (location :number) {
  return [location >> 16, location & 65535]
}

const start :[number, number] = [1, 1]

const offsets = [[1, 0], [-1, 0], [0, 1], [0, -1]]

let locations :Set<number> = new Set([encodeLocation(start)])
const totalLocations :Set<number> = new Set(locations)

for (let ii = 0; ii < 50; ++ii) {
  const nextLocations :Set<number> = new Set()
  for (const location of locations) {
    const pos = decodeLocation(location)
    for (const offset of offsets) {
      const nextPos :[number, number] = [pos[0] + offset[0], pos[1] + offset[1]]
      if (nextPos[0] >= 0 && nextPos[1] >= 0 && !isWall(nextPos)) {
        const encoded = encodeLocation(nextPos)
        nextLocations.add(encoded)
        totalLocations.add(encoded)
      }
    }
  }
  locations = nextLocations
}

console.log(totalLocations.size)

