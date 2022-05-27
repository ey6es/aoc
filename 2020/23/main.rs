fn main () {
    let mut nexts = [0; 1000001];

    let mut first = 0;
    let mut last = 0;
    for value in [3, 1, 5, 6, 7, 9, 8, 2, 4] {
        if first == 0 {
            first = value;
        } else {
            nexts[last] = value;
        }
        last = value;
    }
    for value in 10..1000001 {
        nexts[last] = value;
        last = value;
    }

    nexts[last] = first;

    let mut current = first;
    for _ in 0..10000000 {
        let s0 = nexts[current];
        let s1 = nexts[s0];
        let s2 = nexts[s1];
        nexts[current] = nexts[s2];

        let mut dest = current - 1;
        loop {
            if dest == 0 {
                dest = 1000000;
            } else if dest == s0 || dest == s1 || dest == s2 {
                dest -= 1;
            } else {
                break;
            }
        }

        let following = nexts[dest];
        nexts[dest] = s0;
        nexts[s2] = following;

        current = nexts[current];
    }

    let p0 = nexts[1];
    let p1 = nexts[p0];

    println!("{}", (p0 as u64) * (p1 as u64));
}
