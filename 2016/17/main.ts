import md5 from 'md5'

const input = 'gdjjyniy'

const size = 4

const src :[number, number] = [0, 0]
const dest :[number, number] = [size - 1, size - 1]

function getGoalDistance (pos :[number, number]) {
  return Math.abs(pos[0] - dest[0]) + Math.abs(pos[1] - dest[1])
}

type FringeElement = [number, string, [number, number]]

const fringe :FringeElement[] = [[getGoalDistance(src), '', src]]

function pushFringe (element :FringeElement) {
  let index = fringe.length
  fringe.push(element)
  while (index > 0) {
    const parentIndex = Math.floor((index - 1) / 2)
    if (fringe[parentIndex][0] <= fringe[index][0]) break
    [fringe[index], fringe[parentIndex]] = [fringe[parentIndex], fringe[index]]
    index = parentIndex
  }
}

function popFringe () {
  const top = fringe[0]
  const last = fringe.pop()!
  if (fringe.length > 0) {
    fringe[0] = last
    let index = 0
    while (true) {
      const leftIndex = index * 2 + 1
      if (leftIndex >= fringe.length) break
      const rightIndex = index * 2 + 2
      const lowerIndex = rightIndex < fringe.length && fringe[rightIndex][0] < fringe[leftIndex][0] ? rightIndex : leftIndex
      if (fringe[index][0] <= fringe[lowerIndex][0]) break
      [fringe[index], fringe[lowerIndex]] = [fringe[lowerIndex], fringe[index]]
      index = lowerIndex
    }
  }
  return top
}

function isOpen (ch :string) {
  const value = ch.charCodeAt(0)
  return value >= 'b'.charCodeAt(0) && value <= 'f'.charCodeAt(0)
}

let longestPath = ''

while (fringe.length > 0) {
  const [est, path, pos] = popFringe()
  if (pos[0] === dest[0] && pos[1] === dest[1]) {
    if (path.length > longestPath.length) longestPath = path
    continue
  }
  const hash = md5(input + path)
  if (pos[0] > 0 && isOpen(hash[0])) {
    const nextPos :[number, number] = [pos[0] - 1, pos[1]]
    pushFringe([path.length + getGoalDistance(nextPos), path + 'U', nextPos])
  }
  if (pos[0] < size - 1 && isOpen(hash[1])) {
    const nextPos :[number, number] = [pos[0] + 1, pos[1]]
    pushFringe([path.length + getGoalDistance(nextPos), path + 'D', nextPos])
  }
  if (pos[1] > 0 && isOpen(hash[2])) {
    const nextPos :[number, number] = [pos[0], pos[1] - 1]
    pushFringe([path.length + getGoalDistance(nextPos), path + 'L', nextPos])
  }
  if (pos[1] < size - 1 && isOpen(hash[3])) {
    const nextPos :[number, number] = [pos[0], pos[1] + 1]
    pushFringe([path.length + getGoalDistance(nextPos), path + 'R', nextPos])
  }
}

console.log(longestPath.length)