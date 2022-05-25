use std::collections::HashSet;
use std::fs;
use std::vec::Vec;

struct Entry<'a> {
    ingredients: HashSet<&'a str>,
    allergens: HashSet<&'a str>,
}

fn next_match<'a> (entries: &Vec<Entry<'a>>) -> Option<(&'a str, &'a str)> {
    for entry in entries.iter() {
        for allergen in entry.allergens.iter() {
            let mut ingredients = entry.ingredients.clone();
            for other_entry in entries.iter() {
                if other_entry.allergens.contains(allergen) {
                    ingredients.retain(|ingredient| other_entry.ingredients.contains(ingredient));
                }
            }
            if ingredients.len() == 1 {
                return Some((ingredients.iter().next().unwrap(), allergen));
            }
        }
    }
    None
}

fn main () {
    let input = fs::read_to_string("input.txt").expect("Bad input");
    let mut entries: Vec<_> = input
        .lines()
        .map(|line| {
            let mut parts = line.split(" (contains ");
            let ingredients = parts.next().unwrap();
            let allergens = parts.next().unwrap();
            Entry {
                ingredients: ingredients.split_whitespace().collect(),
                allergens: allergens[..allergens.len() - 1].split(", ").collect(),
            }
        })
        .collect();

    let mut pairs: Vec<_> = Vec::new();

    while let Some((ingredient, allergen)) = next_match(&entries) {
        pairs.push((allergen, ingredient));

        for entry in entries.iter_mut() {
            entry.ingredients.remove(ingredient);
            entry.allergens.remove(allergen);
        }
    }

    println!("{}", entries.iter().map(|entry| entry.ingredients.len()).sum::<usize>());
    println!("{}", entries.iter().map(|entry| entry.allergens.len()).sum::<usize>());

    pairs.sort();

    for (_, ingredient) in pairs.iter() {
        print!("{},", ingredient);
    }
    println!();
}
