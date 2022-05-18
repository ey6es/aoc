use std::fs;

fn main () {
    let count =
        fs::read_to_string("input.txt")
            .expect("Bad input")
            .lines()
            .filter(|line| {
                let mut parts = line.split_whitespace();
                let positions = parts.next().expect("Missing positions");
                let letter = &parts.next().expect("Missing letter")[..1];
                let password = parts.next().expect("Missing password");
                let mut pos_parts = positions.split('-');
                let p0 = pos_parts.next().expect("No p0").parse::<usize>().expect("Bad p0") - 1;
                let p1 = pos_parts.next().expect("No p1").parse::<usize>().expect("Bad p1") - 1;
                let p0_matches = p0 < password.len() && password[p0..p0 + 1] == *letter;
                let p1_matches = p1 < password.len() && password[p1..p1 + 1] == *letter;
                p0_matches ^ p1_matches
            })
            .count();

    println!("{}", count);
}
