import { readFileSync } from 'node:fs'

const values = new Map()
const rules = new Map()

function addValue (id :number, value :number) {
  let array = values.get(id)
  if (!array) values.set(id, array = [])
  array.push(value)
}

for (const line of readFileSync('input.txt', 'utf8').split('\n')) {
  if (line == '') continue
  const parts = line.split(' ')
  if (parts[0] == 'value') {
    addValue(parseInt(parts[5]), parseInt(parts[1]))

  } else {
    rules.set(parseInt(parts[1]), [parseInt(parts[6]), parseInt(parts[11])])
  }
}

while (true) {
  for (const [id, array] of values) {
    const rule = rules.get(id)
    if (array.length == 2 && rule) {
      const lower = Math.min(array[0], array[1])
      const higher = Math.max(array[0], array[1])
      addValue(rule[0], lower)
      addValue(rule[1], higher)
      array.length = 0
    }
  }
  const first = values.get(0)
  const second = values.get(1)
  const third = values.get(2)
  if (first && first.length == 1 && second && second.length == 1 && third && third.length == 1) {
    console.log(first[0] * second[0] * third[0])
    break
  }
}
