(int x, int y) pos = (0, 0);
(int x, int y)[] dirs = {(1, 0), (0, -1), (-1, 0), (0, 1)};

var values = new Dictionary<(int, int), int>();
values.Add((0, 0), 1);

const int input = 368078;
for (int ii = 1, didx = 0, length = 1, rlen = length; ii < input; ++ii) {
  var dir = dirs[didx];
  pos.x += dir.x;
  pos.y += dir.y;
  if (--rlen == 0) {
    didx = (didx + 1) % 4;
    if (didx == 0 || didx == 2) ++length;
    rlen = length;
  }
  var sum = 0;
  for (var dy = -1; dy <= 1; ++dy) {
    for (var dx = -1; dx <= 1; ++dx) {
      if ((dy != 0 || dx != 0) && values.TryGetValue((pos.x + dx, pos.y + dy), out var value)) sum += value;
    }
  }
  if (sum > input) {
    Console.WriteLine(sum);
    break;
  }
  values.Add(pos, sum);
}
