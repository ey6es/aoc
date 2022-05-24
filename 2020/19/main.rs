use std::collections::HashMap;
use std::collections::HashSet;
use std::fs;
use std::vec::Vec;

trait Rule {
    fn matches (&self, rules: &HashMap<usize, Box<dyn Rule>>, message: &str) -> HashSet<usize>;
}

struct Literal {
    character: char,
}
impl Rule for Literal {
    fn matches (&self, _: &HashMap<usize, Box<dyn Rule>>, message: &str) -> HashSet<usize> {
        let mut results = HashSet::new();
        if message.chars().next() == Some(self.character) {
            results.insert(1);
        }
        results
    }
}

struct List {
    rules: Vec<usize>,
}
impl Rule for List {
    fn matches (&self, rules: &HashMap<usize, Box<dyn Rule>>, message: &str) -> HashSet<usize> {
        let mut results = HashSet::from([0]);
        for rule in self.rules.iter() {
            let mut next_results = HashSet::new();
            for start in results.iter() {
                for result in rules.get(rule).unwrap().matches(rules, &message[*start..]) {
                    next_results.insert(start + result);
                }
            }
            results = next_results;
        }
        results
    }
}

struct Or {
    r1: Box<dyn Rule>,
    r2: Box<dyn Rule>,
}
impl Rule for Or {
    fn matches (&self, rules: &HashMap<usize, Box<dyn Rule>>, message: &str) -> HashSet<usize> {
        let mut results = self.r1.matches(rules, message);
        for result in self.r2.matches(rules, message) {
            results.insert(result);
        }
        results
    }
}

fn main () {
    let input = fs::read_to_string("input.txt").expect("Bad input");
    let mut sections = input.split("\n\n");

    let mut rules: HashMap<usize, Box<dyn Rule>> = HashMap::new();

    fn parse_rule (expr: &str) -> Box<dyn Rule> {
        let mut expr_chars = expr.chars();
        if expr_chars.next().unwrap() == '"' {
            return Box::new(Literal{character: expr_chars.next().unwrap()});
        }
        return match expr.find(" | ") {
            Some(index) => {
                Box::new(Or{r1: parse_rule(&expr[..index]), r2: parse_rule(&expr[index + 3..])})
            }
            None => {
                Box::new(List{rules: expr.split(' ').map(|index| index.parse().unwrap()).collect()})
            }
        }
    }

    sections.next().unwrap().lines().for_each(|line| {
        let mut parts = line.split(": ");
        rules.insert(parts.next().unwrap().parse().unwrap(), parse_rule(parts.next().unwrap()));
    });

    let zero = rules.get(&0).unwrap();
    let count = sections
        .next()
        .unwrap()
        .lines()
        .filter(|message| { zero.matches(&rules, message).contains(&message.len()) })
        .count();

    println!("{}", count);
}
