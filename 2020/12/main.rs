use std::fs;

fn main () {
    let final_pos = fs::read_to_string("input.txt")
        .expect("Bad input")
        .lines()
        .fold((0.0, 0.0, 10.0, -1.0), |pos, line| {
            let amount: f64 = line[1..].parse().unwrap();
            match &line[..1] {
                "N" => { (pos.0, pos.1, pos.2, pos.3 - amount) },
                "S" => { (pos.0, pos.1, pos.2, pos.3 + amount) },
                "E" => { (pos.0, pos.1, pos.2 + amount, pos.3) },
                "W" => { (pos.0, pos.1, pos.2 - amount, pos.3)},
                "L" => {
                    let r = amount.to_radians();
                    let rsin = r.sin();
                    let rcos = r.cos();
                    (pos.0, pos.1, pos.2*rcos + pos.3*rsin, -pos.2*rsin + pos.3*rcos)
                },
                "R" => {
                    let r = amount.to_radians();
                    let rsin = r.sin();
                    let rcos = r.cos();
                    (pos.0, pos.1, pos.2*rcos - pos.3*rsin, pos.2*rsin + pos.3*rcos)
                },
                "F" => { (pos.0 + amount * pos.2, pos.1 + amount * pos.3, pos.2, pos.3) },
                _ => { (pos.0, pos.1, pos.2, pos.3) },
            }
        });

    println!("{}", final_pos.0.abs() + final_pos.1.abs());
}
