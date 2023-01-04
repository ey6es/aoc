import { readFileSync } from 'node:fs';

const regex = /^((?:[a-z]+-)+)(\d+)\[([a-z]+)\]$/
for (let line of readFileSync('input.txt', 'utf8').split('\n')) {
  let matches = regex.exec(line)
  if (!matches) continue
  let counts = new Map()
  for (let ch of matches[1]) {
    if (ch != '-') counts.set(ch, (counts.get(ch) ?? 0) + 1)
  }
  let checksum = Array.from(counts.entries()).sort((a, b) => {
    let diff = b[1] - a[1]
    return diff == 0 ? a[0].charCodeAt(0) - b[0].charCodeAt(0) : diff
  }).map(entry => entry[0]).join('').substring(0, 5)
  if (checksum == matches[3]) {
    let offset = parseInt(matches[2])
    let result = ''
    for (let ch of matches[1]) {
      if (ch == '-') result += ' '
      else result += String.fromCharCode('a'.charCodeAt(0) + (ch.charCodeAt(0) - 'a'.charCodeAt(0) + offset) % 26)
    }
    console.log(result + " " + offset)
  }
}
