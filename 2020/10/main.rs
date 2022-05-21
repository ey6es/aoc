use std::fs;
use std::vec::Vec;

fn main () {
    let mut numbers: Vec<i32> = fs::read_to_string("input.txt")
        .expect("Bad input")
        .lines()
        .map(|line| line.parse().unwrap())
        .collect();

    numbers.push(0);
    numbers.sort();

    let mut counts: Vec<usize> = Vec::new();
    counts.resize(numbers.len(), 0);

    counts[numbers.len() - 1] = 1;
    for i in (0..numbers.len() - 1).rev() {
        let original = numbers[i];
        let mut total = 0;
        for offset in 1..4 {
            let j = i + offset;
            if j < numbers.len() && numbers[j] - original <= 3 {
                total += counts[j];
            }
        }
        counts[i] = total;
    }

    println!("{}", counts[0]);
}
