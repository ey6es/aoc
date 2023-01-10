const input = 3018458

const array :number[] = []
for (let ii = 1; ii <= input; ++ii) {
  array.push(ii)
}

let index = 0
while (array.length > 1) {
  if ((array.length % 1000) === 0) console.log(array.length)
  const removeIndex = (index + Math.floor(array.length / 2)) % array.length
  if (removeIndex > index) index++
  array.splice(removeIndex, 1)
  index %= array.length
}

console.log(array[0])