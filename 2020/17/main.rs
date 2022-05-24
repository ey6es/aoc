use std::collections::HashSet;
use std::fs;

fn main () {
    let mut active_locations: HashSet<(i32, i32, i32, i32)> = HashSet::new();

    fs::read_to_string("input.txt")
        .expect("Bad input")
        .lines()
        .enumerate()
        .for_each(|(y, line)| {
            line.chars().enumerate().for_each(|(x, ch)| {
                if ch == '#' {
                    active_locations.insert((x as i32, y as i32, 0, 0));
                }
            });
        });

    fn active_neighbors (locations: &HashSet<(i32, i32, i32, i32)>, pos: (i32, i32, i32, i32)) -> i32 {
        let mut count = 0;
        for ox in -1..2 {
            for oy in -1..2 {
                for oz in -1..2 {
                    for ow in -1..2 {
                        if !(ox == 0 && oy == 0 && oz == 0 && ow == 0) &&
                                locations.contains(&(pos.0 + ox, pos.1 + oy, pos.2 + oz, pos.3 + ow)) {
                            count += 1;
                        }
                    }
                }
            }
        }
        count
    }

    for _ in 0..6 {
        let mut next_active_locations = HashSet::new();
        for (x, y, z, w) in active_locations.iter() {
            let count = active_neighbors(&active_locations, (*x, *y, *z, *w));
            if count == 2 || count == 3 {
                next_active_locations.insert((*x, *y, *z, *w));
            }
            for ox in -1..2 {
                for oy in -1..2 {
                    for oz in -1..2 {
                        for ow in -1..2 {
                            if !(ox == 0 && oy == 0 && oz == 0 && ow == 0) {
                                let neighbor = (x + ox, y + oy, z + oz, w + ow);
                                if !active_locations.contains(&neighbor) &&
                                        !next_active_locations.contains(&neighbor) &&
                                        active_neighbors(&active_locations, neighbor) == 3 {
                                    next_active_locations.insert(neighbor);
                                }
                            }
                        }
                    }
                }
            }
        }
        active_locations = next_active_locations;
    }

    println!("{}", active_locations.len());
}
