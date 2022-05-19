use std::fs;
use std::collections::HashSet;

fn main () {
    fn parse (entry: &str, set: char) -> i32 {
        entry.chars().fold(0, |value, element| {
            (value << 1) + (if element == set {1} else {0})
        })
    }
    let set: HashSet<i32> = fs::read_to_string("input.txt")
        .expect("Bad input")
        .lines()
        .map(|entry| {
            let row = parse(&entry[..7], 'B');
            let col = parse(&entry[7..], 'R');
            row * 8 + col
        })
        .collect();

    for i in 0..1023 {
        if !set.contains(&i) && set.contains(&(i-1)) && set.contains(&(i+1)) {
            println!("{}", i);
        }
    }
}
