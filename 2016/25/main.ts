import { readFileSync } from 'node:fs'

let initialValue = 0
outer: for (let candidate = 0;; ++candidate) {
  let value = candidate + 231 * 11
  const firstParity = value % 2
  let lastParity = firstParity
  while (value > 1) {
    value = Math.floor(value / 2)
    const parity = value % 2
    if (parity === lastParity) continue outer
    lastParity = parity
  }
  if (lastParity !== firstParity) {
    initialValue = candidate
    break
  }
}

console.log(initialValue)

const instructions :Function[] = []
const registers = new Map([['a', initialValue], ['b', 0], ['c', 0], ['d', 0]])
let pc = 0

function createGetter (arg :string) {
  if (registers.has(arg)) return () => registers.get(arg)!
  const value = parseInt(arg)
  return () => value
}

for (let line of readFileSync('input.txt', 'utf8').split('\n')) {
  const parts = line.split(' ')
  switch (parts[0]) {
    case 'cpy': {
      const getter = createGetter(parts[1])
      instructions.push(() => registers.set(parts[2], getter()))
      break
    }
    case 'inc':
      instructions.push(() => registers.set(parts[1], registers.get(parts[1])! + 1))
      break

    case 'dec':
      instructions.push(() => registers.set(parts[1], registers.get(parts[1])! - 1))
      break

    case 'jnz': {
      const firstGetter = createGetter(parts[1])
      const secondGetter = createGetter(parts[2])
      instructions.push(() => { if (firstGetter() !== 0) pc += secondGetter() - 1 })
      break
    }
    case 'out': {
      const getter = createGetter(parts[1])
      instructions.push(() => console.log(getter()))
      break
    }
  }
}

while (pc < instructions.length) instructions[pc++]()

console.log(registers.get('a'))