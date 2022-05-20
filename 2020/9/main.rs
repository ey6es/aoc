use std::collections::HashMap;
use std::collections::HashSet;
use std::fs;
use std::vec::Vec;

fn main () {
    let numbers: Vec<i64> = fs::read_to_string("input.txt")
        .expect("Bad input")
        .lines()
        .map(|line| line.parse().unwrap())
        .collect();

    let mut set = HashSet::new();
    for i in 0..25 {
        set.insert(numbers[i]);
    }

    'outer: for i in 25..numbers.len() {
        let number = numbers[i];
        for j in i - 25..i {
            if set.contains(&(number - numbers[j])) {
                set.remove(&numbers[i - 25]);
                set.insert(number);
                continue 'outer;
            }
        }
        let mut map: HashMap<i64, usize> = HashMap::new();
        let mut total = 0;
        for j in 0..numbers.len() {
            total += numbers[j];
            if let Some(index) = map.get(&(total - number)) {
                let slice = &numbers[index + 1..j + 1];
                println!("{}", slice.iter().min().unwrap() + slice.iter().max().unwrap());
                break 'outer;
            }
            map.insert(total, j);
        }
    }
}
