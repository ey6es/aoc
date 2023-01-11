import { readFileSync } from 'node:fs'

const nodes :[number, number][][] = []

const lines = readFileSync('input.txt', 'utf8').split('\n')

for (let ii = 2; ii < lines.length; ++ii) {
  const parts = lines[ii].split(/\s+/)
  if (parts[2] === undefined) continue
  const coords = parts[0].split('-')
  const [x, y] = [parseInt(coords[1].slice(1)), parseInt(coords[2].slice(1))]
  while (nodes.length <= x) nodes.push([])
  nodes[x].push([parseInt(parts[2].slice(0, -1)), parseInt(parts[3].slice(0, -1))])
}

const width = nodes.length
const height = nodes[0].length

const goal = [width - 1, 0]
const target = [0, 0]

const amount = nodes[goal[0]][goal[1]][0]

let freePos :[number, number] = [0, 0]
const blocked :boolean[][] = []

let moveableCount = 0
let fullCount = 0
for (let xx = 0; xx < width; ++xx) {
  blocked.push([])
  for (let yy = 0; yy < height; ++yy) {
    if (nodes[xx][yy][1] >= amount) freePos = [xx, yy]
    blocked[xx].push(nodes[xx][yy][0] > amount * 2)
  }
}

const leftOfGoal = [goal[0] - 1, goal[1]]

type FringeElement = [number, number, [number, number]]

function getGoalDistance (pos :[number, number]) {
  return Math.abs(pos[0] - leftOfGoal[0]) + Math.abs(pos[1] - leftOfGoal[1])
}

const fringe :FringeElement[] = [[getGoalDistance(freePos), 0, freePos]]

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

const offsets = [[1, 0], [-1, 0], [0, 1], [0, -1]]
const visited = new Set()

let minSteps = 0
while (fringe.length > 0) {
  const [est, steps, pos] = popFringe()
  if (pos[0] === leftOfGoal[0] && pos[1] === leftOfGoal[1]) {
    minSteps = steps
    break
  }
  visited.add(pos.join())
  const nextSteps = 1 + steps
  for (let offset of offsets) {
    const nextPos :[number, number] = [pos[0] + offset[0], pos[1] + offset[1]]
    if (nextPos[0] >= 0 && nextPos[0] < width && nextPos[1] >= 0 && nextPos[1] < height && !visited.has(nextPos.join()) &&
        !blocked[nextPos[0]][nextPos[1]]) {
      pushFringe([nextSteps + getGoalDistance(nextPos), nextSteps, nextPos])
    }
  }
}

console.log(minSteps + (goal[0] - target[0] - 1) * 5 + 1)