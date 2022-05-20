use std::collections::HashMap;
use std::fs;
use std::vec::Vec;

fn main () {
    let input = fs::read_to_string("input.txt").expect("Bad input");
    let mut map = HashMap::new();
    for line in input.lines() {
        let mut sections = line.split(" bags contain ");
        let container = sections.next().unwrap();
        let contents = sections.next().unwrap();

        let mut children = Vec::new();
        if contents != "no other bags." {
            for element in contents.split(", ") {
                let first_space = element.find(' ').unwrap();
                children.push((element[..first_space].parse().unwrap(), &element[first_space + 1..element.rfind(' ').unwrap()]));
            }
        }

        map.insert(container, children);
    }

    fn visit (map: &HashMap<&str, Vec<(usize, &str)>>, color: &str) -> usize {
        map.get(color).unwrap().iter().map(|(count, color)| count * (1 + visit(map, color))).sum()
    }

    println!("{}", visit(&map, "shiny gold"));
}
