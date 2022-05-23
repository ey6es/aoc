use std::collections::HashMap;
use std::fs;
use std::vec::Vec;

fn main () {
    let input = fs::read_to_string("input.txt").expect("Bad input");
    let line = input.lines().next().unwrap();
    let initial: Vec<usize> = line.split(',').map(|entry| entry.parse().unwrap()).collect();

    let mut last: usize = *initial.last().unwrap();
    let mut last_used: HashMap<usize, (usize, usize)> = HashMap::new();
    for i in 0..initial.len() {
        last_used.insert(initial[i], (i, i));
    }
    for i in initial.len()..30000000 {
        let (t0, t1) = last_used.get(&last).unwrap();
        last = t1 - t0;
        let new_entry;
        match last_used.get(&last) {
            Some((_, i1)) => { new_entry = (*i1, i); },
            None => { new_entry = (i, i); },
        }
        last_used.insert(last, new_entry);
    }

    println!("{}", last);
}
