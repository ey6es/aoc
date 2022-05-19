use std::fs;

fn main () {
    let string = fs::read_to_string("input.txt").expect("Bad input");

    let product: usize = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
        .iter()
        .map(|tuple| {
            let mut x = 0;
            string.lines()
                .step_by(tuple.1)
                .filter(|line| {
                    let char = line.chars().cycle().nth(x);
                    x += tuple.0;
                    char == Some('#')
                })
                .count()
        })
        .product();

    println!("{}", product);
}
