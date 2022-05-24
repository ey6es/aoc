use std::fs;
use std::vec::Vec;

fn main () {
    let sum: i64 = fs::read_to_string("input.txt")
        .expect("Bad input")
        .lines()
        .map(|expr| {
            let mut value_stack: Vec<i64> = Vec::new();
            let mut op_stack: Vec<char> = Vec::new();
            let mut chars = expr.chars().enumerate().peekable();
            fn execute_op (op_stack: &mut Vec<char>, value_stack: &mut Vec<i64>) {
                let value = match op_stack.pop().unwrap() {
                    '+' => { value_stack.pop().unwrap() + value_stack.pop().unwrap() },
                    '*' => { value_stack.pop().unwrap() * value_stack.pop().unwrap() },
                    _ => { 0 },
                };
                value_stack.push(value);
            }
            loop {
                match chars.next() {
                    Some((_, '(')) => {
                        op_stack.push('(');
                        continue;
                    },
                    Some((_, ')')) => {
                        while op_stack.last().unwrap() != &'(' {
                            execute_op(&mut op_stack, &mut value_stack);
                        }
                        op_stack.pop();
                    },
                    Some((_, ' ')) => {},
                    Some((_, '+')) => {
                        loop {
                            match op_stack.last() {
                                Some('(') => { break; }
                                Some('*') => { break; }
                                Some(_) => { execute_op(&mut op_stack, &mut value_stack); }
                                None => { break; }
                            }
                        }
                        op_stack.push('+');
                    },
                    Some((_, '*')) => {
                        loop {
                            match op_stack.last() {
                                Some('(') => { break; }
                                Some(_) => { execute_op(&mut op_stack, &mut value_stack); }
                                None => { break; }
                            }
                        }
                        op_stack.push('*');
                    },
                    Some((start, _)) => {
                        value_stack.push(loop {
                            match chars.peek() {
                                Some((end, ch)) => {
                                    if ch == &' ' || ch == &')' {
                                        break expr[start..*end].parse().unwrap();
                                    }
                                }
                                None => { break expr[start..].parse().unwrap(); }
                            }
                        });
                    },
                    None => {
                        while !op_stack.is_empty() {
                            execute_op(&mut op_stack, &mut value_stack);
                        }
                        break;
                    },
                }
            }
            value_stack.pop().unwrap()
        })
        .sum();

    println!("{}", sum);
}
