use std::fs;
use std::vec::Vec;

fn main () {
    let mut rows: Vec<Vec<_>> = fs::read_to_string("input.txt")
        .expect("Bad input")
        .lines()
        .map(|line| line.chars().collect())
        .collect();

    fn count_visible_occupied (rows: &Vec<Vec<char>>, row: usize, col: usize) -> usize {
        let mut visible_occupied = 0;
        for dir in [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)] {
            let mut i = row as isize;
            let mut j = col as isize;
            loop {
                i += dir.0;
                j += dir.1;
                if i < 0 || i >= rows.len() as isize || j < 0 || j >= rows[i as usize].len() as isize {
                    break;
                }
                match rows[i as usize][j as usize] {
                    'L' => { break; },
                    '#' => { visible_occupied += 1; break; },
                    _ => {},
                }
            }
        }
        return visible_occupied;
    }

    loop {
        let mut next_rows = rows.clone();
        let mut changed = false;
        for i in 0..rows.len() {
            let row = &rows[i];
            for j in 0..row.len() {
                match row[j] {
                    'L' => {
                        if count_visible_occupied(&rows, i, j) == 0 {
                            next_rows[i][j] = '#';
                            changed = true;
                        }
                    },
                    '#' => {
                        if count_visible_occupied(&rows, i, j) >= 5 {
                            next_rows[i][j] = 'L';
                            changed = true;
                        }
                    },
                    _ => {},
                }
            }
        }
        if !changed {
            break;
        }
        rows = next_rows;
    };

    println!("{}", rows.iter().map(|row| row.iter().filter(|&ch| ch == &'#').count()).sum::<usize>());
}
