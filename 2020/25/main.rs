use std::fs;

fn get_loops (target: u64) -> u64 {
    let mut loops = 1;
    let mut value = 1;
    loop {
        value = (value * 7) % 20201227;
        if value == target {
            return loops;
        }
        loops += 1;
    }
}

fn transform (subject_number: u64, loops: u64) -> u64 {
    let mut value = 1;
    for _ in 0..loops {
        value = (value * subject_number) % 20201227;
    }
    value
}

fn main () {
    let input = fs::read_to_string("input.txt").unwrap();
    let mut lines = input.lines();
    let card_public_key: u64 = lines.next().unwrap().parse().unwrap();
    let door_public_key: u64 = lines.next().unwrap().parse().unwrap();

    let card_loops = get_loops(card_public_key);
    let door_loops = get_loops(door_public_key);

    println!("{} {}", transform(door_public_key, card_loops), transform(card_public_key, door_loops));
}
