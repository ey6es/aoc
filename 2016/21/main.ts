import { debug } from 'node:console'
import { readFileSync } from 'node:fs'

function positiveModulo (a :number, b :number) {
  const result = a % b
  return result < 0 ? result + b : result
}

let data = 'fbgdceah'

const lines = readFileSync('input.txt', 'utf8').split('\n')
const positionRotations = [1, 1, 6, 2, 7, 3, 0, 4]

for (let ii = lines.length - 1; ii >= 0; --ii) {
  const parts = lines[ii].split(' ')
  switch (parts[0]) {
    case 'swap': {
      const [i0, i1] = parts[1] === 'position'
        ? [parseInt(parts[2]), parseInt(parts[5])]
        : [data.indexOf(parts[2]), data.indexOf(parts[5])]
      const [minIndex, maxIndex] = i0 < i1 ? [i0, i1] : [i1, i0]
      data = data.substring(0, minIndex) + data[maxIndex] + data.substring(minIndex + 1, maxIndex) +
             data[minIndex] + data.substring(maxIndex + 1)
      break
    }
    case 'rotate': {
      const steps = parts[1] === 'left'
        ? -parseInt(parts[2])
        : parts[1] === 'right'
        ? parseInt(parts[2])
        : positionRotations[data.indexOf(parts[6])]
      let rotated = ''
      for (let jj = 0; jj < data.length; ++jj) {
        rotated += data[positiveModulo(jj + steps, data.length)]
      }
      data = rotated
      break
    }
    case 'reverse': {
      const start = parseInt(parts[2])
      const end = parseInt(parts[4])
      let reversed = data.substring(0, start)
      for (let jj = end; jj >= start; --jj) {
        reversed += data[jj]
      }
      data = reversed + data.substring(end + 1)
      break
    }
    case 'move':
      const to = parseInt(parts[2])
      const from = parseInt(parts[5])
      const removed = data.substring(0, from) + data.substring(from + 1)
      data = removed.substring(0, to) + data[from] + removed.substring(to)
      break
  }
}

console.log(data)