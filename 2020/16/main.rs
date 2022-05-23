use std::collections::HashSet;
use std::fs;
use std::ops::Range;
use std::vec::Vec;

struct Field<'a> {
    name: &'a str,
    ranges: [Range<i64>; 2],
    pos: usize,
}

fn main () {
    let input = fs::read_to_string("input.txt").expect("Bad input");
    let mut lines = input.lines();

    let mut fields: Vec<Field> = Vec::new();
    loop {
        match lines.next().unwrap() {
            "" => { break; },
            entry => {
                let mut parts = entry.split(": ");
                let name = parts.next().unwrap();
                let mut ranges = parts.next().unwrap().split(" or ").map(|range| {
                    let mut ends = range.split('-').map(|end| end.parse().unwrap());
                    Range{start: ends.next().unwrap(), end: ends.next().unwrap() + 1}
                });
                fields.push(Field {
                    name: name,
                    ranges: [ranges.next().unwrap(), ranges.next().unwrap()],
                    pos: 0,
                });
            },
        }
    }

    lines.next(); // your ticket:

    let your_ticket: Vec<i64> =
        lines.next().unwrap().split(',').map(|value| value.parse().unwrap()).collect();

    lines.next(); //
    lines.next(); // nearby tickets:

    let mut nearby_tickets: Vec<Vec<i64>> = Vec::new();
    for line in lines {
        nearby_tickets.push(line.split(',').map(|value| value.parse().unwrap()).collect());
    }

    nearby_tickets.retain(|ticket| {
        'value_loop: for value in ticket.iter() {
            for field in fields.iter() {
                if field.ranges[0].contains(&value) || field.ranges[1].contains(&value) {
                    continue 'value_loop;
                }
            }
            return false;
        }
        true
    });

    let mut candidates: Vec<HashSet<usize>> = Vec::new();
    candidates.resize(your_ticket.len(), HashSet::new());

    for i in 0..your_ticket.len() {
        'field_loop: for (index, field) in fields.iter().enumerate() {
            for ticket in nearby_tickets.iter() {
                let value = ticket[i];
                if !(field.ranges[0].contains(&value) || field.ranges[1].contains(&value)) {
                    continue 'field_loop;
                }
            }
            candidates[i].insert(index);
        }
    }

    'candidate_loop: loop {
        for i in 0..candidates.len() {
            if candidates[i].len() == 1 {
                let index = *candidates[i].iter().next().unwrap();
                fields[index].pos = i;
                for j in 0..candidates.len() {
                    candidates[j].remove(&index);
                }
                continue 'candidate_loop;
            }
        }
        break;
    }

    println!("{}", fields
        .iter()
        .filter(|field| field.name.starts_with("departure"))
        .map(|field| your_ticket[field.pos])
        .product::<i64>());
}
