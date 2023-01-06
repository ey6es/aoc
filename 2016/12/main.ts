import { readFileSync } from 'node:fs'

const instructions :Function[] = []
const registers = new Map([['a', 0], ['b', 0], ['c', 1], ['d', 0]])
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
  }
}

while (pc < instructions.length) instructions[pc++]()

console.log(registers.get('a'))
