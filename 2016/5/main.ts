import md5 from 'md5';

const input = 'cxdnnyjw'

let password = new Array(8)
let remainingChars = 8
for (let ii = 0;; ++ii) {
  let hash = md5(input + ii)
  if (hash.substring(0, 5) == '00000') {
    let position = hash.charCodeAt(5) - '0'.charCodeAt(0)
    if (position >= 0 && position <= 7 && password[position] === undefined) {
      password[position] = hash[6]
      if (--remainingChars === 0) break
    }
  }
}

console.log(password.join(''))