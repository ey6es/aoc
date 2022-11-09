var states = new Dictionary<(int, int), State>();

(int x, int y) pos = (0, 0);
foreach (var line in File.ReadLines("input.txt")) {
  pos.x = 0;
  foreach (var ch in line) {
    if (ch == '#') states[pos] = State.Infected;
    ++pos.x;
  }
  ++pos.y;
}

pos.x /= 2;
pos.y /= 2;

(int x, int y)[] offsets = new[] {(0, -1), (1, 0), (0, 1), (-1, 0)};
var dir = 0;

var count = 0;
for (var ii = 0; ii < 10000000; ++ii) {
  var state = State.Clean;
  states.TryGetValue(pos, out state);
  switch (state) {
    case State.Clean:
      dir = (dir + 3) % offsets.Length;
      states[pos] = State.Weakened;
      break;

    case State.Weakened:
      states[pos] = State.Infected;
      ++count;
      break;

    case State.Infected:
      dir = (dir + 1) % offsets.Length;
      states[pos] = State.Flagged;
      break;

    case State.Flagged:
      dir = (dir + 2) % offsets.Length;
      states.Remove(pos);
      break;
  }
  var offset = offsets[dir];
  pos.x += offset.x;
  pos.y += offset.y;
}

Console.WriteLine(count);

enum State { Clean, Weakened, Infected, Flagged };
