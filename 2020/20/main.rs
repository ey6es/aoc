use std::collections::HashMap;
use std::collections::HashSet;
use std::cmp;
use std::fs;
use std::iter::FromIterator;
use std::vec::Vec;

fn flip_vertical (data: &mut Vec<Vec<char>>) {
    for i in 0..data.len() / 2 {
        let j = data.len() - i - 1;
        data.swap(i, j);
    }
}

fn flip_horizontal (data: &mut Vec<Vec<char>>) {
    for line in data.iter_mut() {
        for i in 0..line.len() / 2 {
            let j = line.len() - i - 1;
            line.swap(i, j);
        }
    }
}

fn rotate (data: &mut Vec<Vec<char>>) {
    let mut new_data = Vec::new();

    for row in 0..data[0].len() {
        let mut new_row = Vec::new();
        for col in 0..data.len() {
            new_row.push(data[data.len() - col - 1][row]);
        }
        new_data.push(new_row);
    }

    *data = new_data;
}

#[derive(Clone)]
struct Tile {
    _id: u64,
    edges: [u32; 4],
    interior: Vec<Vec<char>>,
    x: i32,
    y: i32,
}
impl Tile {
    fn rotate (&mut self, amount: usize) {
        let mut new_edges = self.edges;
        for i in 0..4 {
            new_edges[(i + amount) % 4] = self.edges[i];
        }
        self.edges = new_edges;

        for _ in 0..amount % 4 {
            rotate(&mut self.interior);
        }
    }

    fn flip_horizontal (&mut self) {
        self.edges[0] = reverse(self.edges[0]);
        let tmp = self.edges[1];
        self.edges[1] = reverse(self.edges[3]);
        self.edges[2] = reverse(self.edges[2]);
        self.edges[3] = reverse(tmp);

        flip_horizontal(&mut self.interior);
    }

    fn flip_vertical (&mut self) {
        let tmp = self.edges[0];
        self.edges[0] = reverse(self.edges[2]);
        self.edges[1] = reverse(self.edges[1]);
        self.edges[2] = reverse(tmp);
        self.edges[3] = reverse(self.edges[3]);

        flip_vertical(&mut self.interior);
    }

    fn flip (&mut self, edge: usize) {
        if edge % 2 == 0 {
            self.flip_horizontal();
        } else {
            self.flip_vertical();
        }
    }
}

fn parse_row (str: &str) -> u32 {
    str.chars().fold(0, |acc, ch| (acc << 1) | if ch == '#' {1} else {0})
}

const SERPENT_CHARS: [&str; 3] = [
    "                  # ",
    "#    ##    ##    ###",
    " #  #  #  #  #  #   ",
];

fn remove_serpents (data: &mut Vec<Vec<char>>) -> usize {
    let mut count = 0;
    for start_y in 0..data.len() - 3 {
        'outer: for start_x in 0..data[0].len() - SERPENT_CHARS[0].len() {
            for y in 0..3 {
                for x in 0..SERPENT_CHARS[0].len() {
                    if &SERPENT_CHARS[y][x..x + 1] == "#" && data[start_y + y][start_x + x] != '#' {
                        continue 'outer;
                    }
                }
            }

            for y in 0..3 {
                for x in 0..SERPENT_CHARS[0].len() {
                    if &SERPENT_CHARS[y][x..x + 1] == "#" {
                        data[start_y + y][start_x + x] = '.';
                    }
                }
            }

            count += 1;
        }
    }
    if count > 0 {
        data.iter().map(|line| line.iter().filter(|&ch| ch == &'#').count()).sum()
    } else {0}
}

fn reverse (edge: u32) -> u32 {
    let mut reversed = 0;
    for i in 0..10 {
        reversed <<= 1;
        if edge & (1 << i) != 0 {
            reversed |= 1;
        }
    }
    reversed
}

fn main () {
    let mut tiles: Vec<_> = fs::read_to_string("input.txt")
        .expect("Bad input")
        .split("\n\n")
        .map(|section| {
            let mut lines = section.lines();
            let title = lines.next().unwrap();
            let first_line = lines.next().unwrap();
            let top = parse_row(first_line);
            let mut right = top & 1;
            let mut left = top >> 9;
            let mut last = 0;
            let mut interior = Vec::new();
            for line in lines {
                last = parse_row(line);
                if interior.len() < 8 {
                    let mut internal: Vec<char> = line.chars().skip(1).collect();
                    internal.pop();
                    interior.push(internal);
                }
                right = (right << 1) | (last & 1);
                left = (left << 1) | (last >> 9);
            }
            Tile {
                _id: title[5..title.len() - 1].parse().unwrap(),
                edges: [top, right, reverse(last), reverse(left)],
                interior: interior,
                x: 0, y: 0,
            }
        })
        .collect();

    let mut edges: HashMap<u32, HashSet<usize>> = HashMap::new();

    for (index, tile) in tiles.iter().enumerate() {
        for edge in tile.edges {
            for value in [edge, reverse(edge)] {
                match edges.get_mut(&value) {
                    Some(set) => { set.insert(index); },
                    None => { edges.insert(value, HashSet::from([index])); },
                }
            }
        }
    }

    let mut processing: HashSet<usize> = HashSet::from([0]);
    let mut unplaced: HashSet<usize> = HashSet::from_iter(1..tiles.len());

    const EDGE_OFFSETS: [(i32, i32); 4] = [(0, -1), (1, 0), (0, 1), (-1, 0)];

    let mut min_x = i32::MAX;
    let mut min_y = i32::MAX;
    let mut max_x = i32::MIN;
    let mut max_y = i32::MIN;

    while processing.len() > 0 {
        let index = *processing.iter().next().unwrap();
        processing.remove(&index);
        let current = tiles[index].clone();

        'edge_loop: for edge_index in 0..4 {
            let edge = current.edges[edge_index];
            let reverse_edge = reverse(edge);
            for value in [edge, reverse_edge] {
                if let Some(set) = edges.get(&value) {
                    for match_index in set.iter() {
                        if unplaced.contains(match_index) {
                            let neighbor = &mut tiles[*match_index];
                            let offset = EDGE_OFFSETS[edge_index];
                            neighbor.x = current.x + offset.0;
                            neighbor.y = current.y + offset.1;
                            min_x = cmp::min(min_x, neighbor.x);
                            min_y = cmp::min(min_y, neighbor.y);
                            max_x = cmp::max(max_x, neighbor.x);
                            max_y = cmp::max(max_y, neighbor.y);

                            let opp_index = (edge_index + 2) % 4;
                            for other_edge_index in 0..4 {
                                let other_edge = neighbor.edges[other_edge_index];
                                if other_edge == edge {
                                    neighbor.rotate(4 + opp_index - other_edge_index);
                                    neighbor.flip(opp_index);
                                    break;

                                } else if other_edge == reverse_edge {
                                    neighbor.rotate(4 + opp_index - other_edge_index);
                                    break;
                                }
                            }

                            unplaced.remove(match_index);
                            processing.insert(*match_index);
                            continue 'edge_loop;
                        }
                    }
                }
            }
        }
    }

    let width = ((max_x - min_x + 1) * 8) as usize;
    let height = ((max_y - min_y + 1) * 8) as usize;

    let mut stitched: Vec<Vec<char>> = Vec::new();
    let mut line = Vec::new();
    line.resize(width, ' ');
    stitched.resize(height, line);

    for tile in tiles.iter() {
        let mut y = ((tile.y - min_y) * 8) as usize;

        for row in tile.interior.iter() {
            let mut x = ((tile.x - min_x) * 8) as usize;

            for value in row.iter() {
                stitched[y][x] = *value;
                x += 1;
            }
            y += 1;
        }
    }

    for _ in 0..4 {
        let count = remove_serpents(&mut stitched);
        if count > 0 {
            println!("{}", count);
        }
        rotate(&mut stitched);
    }

    flip_vertical(&mut stitched);

    for _ in 0..4 {
        let count = remove_serpents(&mut stitched);
        if count > 0 {
            println!("{}", count);
        }
        rotate(&mut stitched);
    }
}
