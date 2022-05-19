use std::fs;
use std::collections::HashSet;

fn main () {
    let sum: usize = fs::read_to_string("input.txt")
        .expect("Bad input")
        .split("\n\n")
        .map(|entry| {
            let mut lines = entry.lines();
            let mut set: HashSet<_> =
                lines.next().unwrap().chars().filter(|&ch| ch != '\n').collect();
            for line in lines {
                let next_set: HashSet<_> = line.chars().collect();
                set.retain(|ch| next_set.contains(ch));
            }
            set.len()
        })
        .sum();

    println!("{}", sum);
}
