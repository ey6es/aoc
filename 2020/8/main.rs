use std::fs;
use std::vec::Vec;

#[derive(Clone)]
enum InstructionKind { Acc, Jmp, Nop }

#[derive(Clone)]
struct Instruction {
    kind: InstructionKind,
    value: i32,
    visited: bool,
}

fn main () {
    let lines: Vec<_> = fs::read_to_string("input.txt")
        .expect("Bad input")
        .lines()
        .map(|line| {
            Instruction {
                kind: if line.starts_with("acc") {
                    InstructionKind::Acc
                } else if line.starts_with("jmp") {
                    InstructionKind::Jmp
                } else {
                    InstructionKind::Nop
                },
                value: line.split_whitespace().last().unwrap().parse().unwrap(),
                visited: false,
            }
        })
        .collect();

    'outer: for i in 0..lines.len() - 1 {
        let new_kind: InstructionKind;
        match lines[i].kind {
            InstructionKind::Acc => continue,
            InstructionKind::Jmp => new_kind = InstructionKind::Nop,
            InstructionKind::Nop => new_kind = InstructionKind::Jmp,
        }
        let mut cloned_lines = lines.clone();
        cloned_lines[i].kind = new_kind;

        let mut pc: i32 = 0;
        let mut acc: i32 = 0;
        loop {
            if pc == cloned_lines.len() as i32 {
                println!("{}", acc);
                break 'outer;
            }
            let instruction = &mut cloned_lines[pc as usize];
            if instruction.visited {
                break;
            }
            instruction.visited = true;
            match instruction.kind {
                InstructionKind::Acc => { acc += instruction.value; pc += 1 },
                InstructionKind::Jmp => pc += instruction.value,
                InstructionKind::Nop => pc += 1,
            }
        }
    }
}
