use std::collections::HashMap;
use std::fs;

fn main () {
    let mut memory: HashMap<u64, u64> = HashMap::new();
    let mut floating: u64 = 0;
    let mut floating_count: u64 = 0;
    let mut set: u64 = 0;
    for line in fs::read_to_string("input.txt").expect("Bad input").lines() {
        let mut parts = line.split(" = ");
        let first = parts.next().unwrap();
        if first == "mask" {
            let bits = parts.next().unwrap();
            floating = 0;
            floating_count = 0;
            set = 0;
            for ch in bits.chars() {
                floating <<= 1;
                set <<= 1;
                match ch {
                    'X' => { floating |= 1; floating_count += 1 },
                    '1' => { set |= 1 },
                    _ => {},
                }
            }
        } else {
            let key: u64 = first[first.find('[').unwrap() + 1..first.len() - 1].parse().unwrap();
            let value: u64 = parts.next().unwrap().parse().unwrap();
            let base = (key & !floating) | set;
            for i in 0..(1_u64 << floating_count) {
                let mut address = base;
                let mut i_bit = 1;
                for j in 0..36 {
                    let floating_bit = 1 << j;
                    if (floating & floating_bit) != 0 {
                        if (i & i_bit) != 0 {
                            address |= floating_bit;
                        }
                        i_bit <<= 1;
                    }
                }
                memory.insert(address, value);
            }
        }
    }

    println!("{}", memory.values().sum::<u64>());
}
