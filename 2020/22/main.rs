use std::collections::HashMap;
use std::collections::HashSet;
use std::collections::VecDeque;
use std::fs;
use std::vec::Vec;

fn main () {
    let decks: Vec<VecDeque<usize>> = fs::read_to_string("input.txt")
        .expect("Bad input")
        .split("\n\n")
        .map(|player| {
            let mut lines = player.lines();
            lines.next();
            lines.map(|line| line.parse().unwrap()).collect()
        })
        .collect();

    fn score (cards: &VecDeque<usize>) -> usize {
        cards.iter().enumerate().map(|(i, value)| value * (cards.len() - i)).sum()
    }

    let mut cached: HashMap<Vec<VecDeque<usize>>, bool> = HashMap::new();

    fn recursive_combat (
        cached: &mut HashMap<Vec<VecDeque<usize>>, bool>,
        decks: &Vec<VecDeque<usize>>,
        p1: usize,
        p2: usize
    ) -> (bool, usize) {
        if decks[0].len() < p1 || decks[1].len() < p2 {
            if p1 > p2 {
                return (true, score(&decks[0]));
            } else {
                return (false, score(&decks[1]));
            }
        }
        let mut next_decks: Vec<VecDeque<usize>> =
            Vec::from([decks[0].range(..p1).copied().collect(), decks[1].range(..p2).copied().collect()]);
        if let Some(cached_result) = cached.get(&next_decks) {
            if *cached_result {
                return (true, score(&next_decks[0]));
            } else {
                return (false, score(&next_decks[1]));
            }
        }

        let mut played: HashSet<Vec<VecDeque<usize>>> = HashSet::new();
        while next_decks[0].len() > 0 && next_decks[1].len() > 0 {
            if played.contains(&next_decks) {
                let next_p1 = next_decks[0].pop_front().unwrap();
                let next_p2 = next_decks[1].pop_front().unwrap();
                next_decks[0].push_back(next_p1);
                next_decks[0].push_back(next_p2);
                continue;
            }
            played.insert(next_decks.clone());

            let next_p1 = next_decks[0].pop_front().unwrap();
            let next_p2 = next_decks[1].pop_front().unwrap();

            if recursive_combat(cached, &next_decks, next_p1, next_p2).0 {
                next_decks[0].push_back(next_p1);
                next_decks[0].push_back(next_p2);

            } else {
                next_decks[1].push_back(next_p2);
                next_decks[1].push_back(next_p1);
            }
        }
        let initial_next_decks =
            Vec::from([decks[0].range(..p1).copied().collect(), decks[1].range(..p2).copied().collect()]);
        if next_decks[0].len() > 0 {
            cached.insert(initial_next_decks, true);
            (true, score(&next_decks[0]))
        } else {
            cached.insert(initial_next_decks, false);
            (false, score(&next_decks[1]))
        }
    }

    println!("{}", recursive_combat(&mut cached, &decks, decks[0].len(), decks[1].len()).1);
}
