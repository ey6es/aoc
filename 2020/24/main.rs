use std::collections::HashSet;
use std::fs;

fn main () {
    let mut black: HashSet<(i32, i32)> = HashSet::new();

    fs::read_to_string("input.txt")
        .unwrap()
        .lines()
        .for_each(|line| {
            let mut chars = line.chars();
            let mut pos = (0, 0);
            loop {
                match chars.next() {
                    Some('e') => { pos.0 += 1; },
                    Some('w') => { pos.0 -= 1; },
                    Some(ns) => {
                        if pos.1 % 2 == 0 {
                            if Some('e') == chars.next() { pos.0 += 1; }
                        } else {
                            if Some('w') == chars.next() { pos.0 -= 1; }
                        }
                        if ns == 'n' {
                            pos.1 -= 1;
                        } else {
                            pos.1 += 1;
                        }
                    },
                    _ => { break; }
                }
            }
            if black.contains(&pos) {
                black.remove(&pos);
            } else {
                black.insert(pos);
            }
        });

    fn get_neighbors (pos: (i32, i32)) -> [(i32, i32); 6] {
        let offset = if pos.1 % 2 == 0 {1} else {-1};
        return [
            (pos.0 - 1, pos.1),
            (pos.0 + 1, pos.1),
            (pos.0, pos.1 - 1),
            (pos.0 + offset, pos.1 - 1),
            (pos.0, pos.1 + 1),
            (pos.0 + offset, pos.1 + 1),
        ];
    }

    fn count_black_neighbors (black: &HashSet<(i32, i32)>, pos: (i32, i32)) -> i32 {
        let mut count = 0;
        for npos in get_neighbors(pos) {
            if black.contains(&npos) { count += 1; }
        }
        return count;
    }

    for _ in 0..100 {
        let mut next_black = HashSet::new();

        for pos in black.iter() {
            let black_neighbors = count_black_neighbors(&black, *pos);
            if black_neighbors == 1 || black_neighbors == 2 {
                next_black.insert(*pos);
            }
            for npos in get_neighbors(*pos) {
                if !black.contains(&npos) && count_black_neighbors(&black, npos) == 2 {
                    next_black.insert(npos);
                }
            }
        }

        black = next_black;
    }

    println!("{}", black.len());
}
