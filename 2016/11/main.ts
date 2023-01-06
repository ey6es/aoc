import { readFileSync } from 'node:fs'

const lines = readFileSync('input.txt', 'utf8').split('\n')

let startState = 0
const elements :string[] = []
for (let ii = 0; ii < 4; ++ii) {
  const parts = lines[ii].split(' ')
  if (parts[4] === 'nothing') continue
  for (let jj = 6; jj < parts.length; ++jj) {
    let element = ''
    let offset = 0
    if (parts[jj].startsWith('generator')) {
      element = parts[jj - 1]

    } else if (parts[jj].startsWith('microchip')) {
      element = parts[jj - 1].split('-')[0]
      offset = 1

    } else {
      continue
    }
    let index = elements.indexOf(element)
    if (index == -1) {
      index = elements.length
      elements.push(element)
    }
    startState |= ii << 2 * (1 + index * 2 + offset)
  }
}

const goalState = (1 << 2 + elements.length * 4) - 1

function isStateValid (state :number) {
  for (let ii = 0; ii < elements.length; ++ii) {
    const chipLevel = (state >> 2 + ii * 4 + 2) & 3
    if (chipLevel === ((state >> 2 + ii * 4) & 3)) continue
    for (let jj = 0; jj < elements.length; ++jj) {
      if (chipLevel === ((state >> 2 + jj * 4) & 3)) return false
    }
  }
  return true
}

let states = new Set([startState])
for (let step = 0;; ++step) {
  if (states.has(goalState)) {
    console.log(step)
    break
  }
  let nextStates :Set<number> = new Set()
  for (const state of states) {
    const elevatorLevel = state & 3
    function addStates (nextElevatorLevel :number) {
      const nextState = state ^ elevatorLevel | nextElevatorLevel
      for (let ii = 0, nn = elements.length * 2; ii < nn; ++ii) {
        const iiShift = 2 + ii * 2
        if ((nextState >> iiShift & 3) !== elevatorLevel) continue
        const iiState = nextState ^ (elevatorLevel << iiShift) | (nextElevatorLevel << iiShift)
        if (isStateValid(iiState)) nextStates.add(iiState)
        for (let jj = 0; jj < nn; ++jj) {
          const jjShift = 2 + jj * 2
          if ((iiState >> jjShift & 3) !== elevatorLevel) continue
          const jjState = iiState ^ (elevatorLevel << jjShift) | (nextElevatorLevel << jjShift)
          if (isStateValid(jjState)) nextStates.add(jjState)
        }
      }
    }
    if (elevatorLevel > 0) addStates(elevatorLevel - 1)
    if (elevatorLevel < 3) addStates(elevatorLevel + 1)
  }
  states = nextStates
}