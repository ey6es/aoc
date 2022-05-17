use std::collections::HashSet;
use std::fs;

fn main () {
    let numbers: HashSet<i32> =
        fs::read_to_string("input.txt")
            .expect("Bad input")
            .lines()
            .map(|line| line.parse().expect("Bad entry"))
            .collect();

    for n0 in numbers.iter() {
        for n1 in numbers.iter() {
            let n2 = 2020 - n0 - n1;
            if numbers.contains(&n2) {
                println!("{}", n0 * n1 * n2);
            }
        }
    }
}
