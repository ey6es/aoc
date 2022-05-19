use std::collections::HashMap;
use std::collections::HashSet;
use std::fs;

fn main () {
    let mut elements: HashMap<_, Box<dyn Fn(&str) -> bool>> = HashMap::new();

    elements.insert("byr", Box::new(|value| {
        let year = value.parse::<i32>().unwrap_or(0);
        year >= 1920 && year <= 2002
    }));

    elements.insert("iyr", Box::new(|value| {
        let year = value.parse::<i32>().unwrap_or(0);
        year >= 2010 && year <= 2020
    }));

    elements.insert("eyr", Box::new(|value| {
        let year = value.parse::<i32>().unwrap_or(0);
        year >= 2020 && year <= 2030
    }));

    elements.insert("hgt", Box::new(|value| {
        let amount = value[..value.len() - 2].parse().unwrap_or(0);
        if value.ends_with("cm") {
            amount >= 150 && amount <= 193
        } else {
            amount >= 59 && amount <= 76
        }
    }));

    elements.insert("hcl", Box::new(|value| {
        value.len() == 7 && value.starts_with("#") && i32::from_str_radix(&value[1..], 16).is_ok()
    }));

    let colors = HashSet::from(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]);

    elements.insert("ecl", Box::new(move |value| {
        colors.contains(value)
    }));

    elements.insert("pid", Box::new(|value| {
        value.len() == 9 && value.parse::<i32>().is_ok()
    }));

    let count = fs::read_to_string("input.txt")
        .expect("Bad input")
        .split("\n\n")
        .filter(|entry| {
            let mut valid = 0;
            entry.split_whitespace().for_each(|element| {
                let mut parts = element.split(':');
                if let Some(validator) = elements.get(parts.next().unwrap()) {
                    if validator(parts.next().unwrap()) {
                        valid += 1;
                    }
                }
            });
            valid == elements.len()
        })
        .count();

    println!("{}", count);
}
