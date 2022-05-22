use std::fs;
use std::vec::Vec;

fn main () {
    let input = fs::read_to_string("input.txt").expect("Bad input");
    let mut lines = input.lines();
    lines.next();

    let entries: Vec<(i64, i64)> = lines
        .next()
        .unwrap()
        .split(',')
        .enumerate()
        .filter(|(_, element)| element != &"x")
        .map(|(i, element)| { (element.parse().unwrap(), i as i64) })
        .collect();

    let first = &entries[0];
    let mut interval = first.0;
    let mut offset = first.1;

    for i in 1..entries.len() {
        let next = &entries[i];
        let mut factor = 0;
        loop {
            if (offset + interval * factor + next.1) % next.0 == 0 {
                break;
            }
            factor += 1;
        }
        offset += interval * factor;
        interval *= next.0;
    }

    println!("{}", offset);
}
