var chars = Enumerable.Range(0, 16).Select(ii => (char)('a' + ii)).ToArray();

void Swap (int i0, int i1) {
  var tmp = chars[i0];
  chars[i0] = chars[i1];
  chars[i1] = tmp;
}

var moves = File.ReadLines("input.txt").First().Split(',').ToArray();

var results = new Dictionary<string, int>();

for (int tt = 0, ll = 1000000000; tt < ll; ++tt) {
  foreach (var move in moves) {
    switch (move[0]) {
      case 's':
        var length = int.Parse(move.Substring(1));
        var newChars = new char[16];
        for (var ii = 0; ii < 16; ++ii) newChars[ii] = chars[(ii + 16 - length) % 16];
        chars = newChars;
        break;

      case 'x':
        var idx = move.IndexOf('/');
        Swap(int.Parse(move.Substring(1, idx - 1)), int.Parse(move.Substring(idx + 1)));
        break;

      case 'p':
        Swap(Array.IndexOf(chars, move[1]), Array.IndexOf(chars, move[3]));
        break;
    }
  }
  if (ll < 1000000000) continue;

  var result = new String(chars);
  if (results.TryGetValue(result, out var index)) {
    Console.WriteLine($"{tt} repeat of {index}");
    ll = tt + (ll % tt);
    continue;
  }
  results[result] = tt;
}

Console.WriteLine(new String(chars));
