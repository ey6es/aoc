import { readFileSync } from 'node:fs'

const registers = new Map([['a', 12], ['b', 0], ['c', 0], ['d', 0]])
let pc = 0

abstract class Value {
  abstract get () :number
  abstract set (value :number) :void
}

class LiteralValue extends Value {
  value :number

  constructor (value :number) {
    super()
    this.value = value
  }

  get () {
    return this.value
  }

  set (value :number) {
    // no-op
  }
}

class RegisterValue extends Value {
  name :string

  constructor (name :string) {
    super()
    this.name = name
  }

  get () {
    return registers.get(this.name)!
  }

  set (value :number) {
    registers.set(this.name, value)
  }
}

function createValue (arg :string) {
  return registers.has(arg) ? new RegisterValue(arg) : new LiteralValue(parseInt(arg))
}

abstract class Instruction {
  abstract execute () :void
  abstract toggle () :Instruction
}

abstract class OneArgInstruction extends Instruction {
  arg :Value

  constructor (arg :Value) {
    super()
    this.arg = arg
  }

  toggle () {
    return new Inc(this.arg)
  }
}

abstract class TwoArgInstruction extends Instruction {
  a :Value
  b :Value

  constructor (a :Value, b :Value) {
    super()
    this.a = a
    this.b = b
  }

  toggle () {
    return new Jnz(this.a, this.b)
  }
}

class Cpy extends TwoArgInstruction {
  
  execute () {
    this.b.set(this.a.get())
  }
}

class Mul extends TwoArgInstruction {
  
  execute () {
    this.b.set(this.a.get() * this.b.get())
  }
}

class Inc extends OneArgInstruction {
  
  execute () {
    this.arg.set(this.arg.get() + 1)
  }

  toggle () {
    return new Dec(this.arg)
  }
}

class Dec extends OneArgInstruction {
  
  execute () {
    this.arg.set(this.arg.get() - 1)
  }
}

class Jnz extends TwoArgInstruction {
  
  execute () {
    if (this.a.get() !== 0) pc += this.b.get() - 1
  }

  toggle () {
    return new Cpy(this.a, this.b)
  }
}

class Tgl extends OneArgInstruction {

  execute () {
    const index = pc + this.arg.get() - 1
    if (index >= 0 && index < instructions.length) instructions[index] = instructions[index].toggle()
  }
}

const instructions :Instruction[] = []

for (let line of readFileSync('input.txt', 'utf8').split('\n')) {
  const parts = line.split(' ')
  switch (parts[0]) {
    case 'cpy': 
      instructions.push(new Cpy(createValue(parts[1]), createValue(parts[2])))
      break
    
    case 'mul':
      instructions.push(new Mul(createValue(parts[1]), createValue(parts[2])))
      break

    case 'inc':
      instructions.push(new Inc(createValue(parts[1])))
      break

    case 'dec':
      instructions.push(new Dec(createValue(parts[1])))
      break

    case 'jnz': 
      instructions.push(new Jnz(createValue(parts[1]), createValue(parts[2])))
      break
    
    case 'tgl':
      instructions.push(new Tgl(createValue(parts[1])))
      break
  }
}

while (pc < instructions.length) instructions[pc++].execute()

console.log(registers.get('a'))