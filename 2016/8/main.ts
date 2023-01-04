import { readFileSync } from 'node:fs'

const width = 50
const height = 6

const pixels :boolean[][] = []
for (let row = 0; row < height; ++row) {
  const line: boolean[] = []
  for (let col = 0; col < width; ++col) line.push(false)
  pixels.push(line) 
}

for (let line of readFileSync('input.txt', 'utf8').split('\n')) {
  if (line == '') continue
  const parts = line.split(' ')
  if (parts[0] == 'rect') {
    const dims = parts[1].split('x').map(d => parseInt(d))
    for (let row = 0; row < dims[1]; ++row) {
      for (let col = 0; col < dims[0]; ++col) pixels[row][col] = true
    }
  } else {
    const coord = parseInt(parts[2].split('=')[1])
    const amount = parseInt(parts[4])
    if (parts[1] == 'row') {
      for (let ii = 0; ii < amount; ++ii) {
        for (let jj = width - 1; jj > 0; --jj) {
          let tmp = pixels[coord][jj - 1]
          pixels[coord][jj - 1] = pixels[coord][jj]
          pixels[coord][jj] = tmp
        }
      }
    } else {
      for (let ii = 0; ii < amount; ++ii) {
        for (let jj = height - 1; jj > 0; --jj) {
          let tmp = pixels[jj - 1][coord]
          pixels[jj - 1][coord] = pixels[jj][coord]
          pixels[jj][coord] = tmp
        }
      }
    }
  }
}

let result = ''
for (let line of pixels) {
  for (let value of line) {
    result += value ? 'X' : ' '
  }
  result += '\n'
}
console.log(result)
