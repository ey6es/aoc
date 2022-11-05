using System.Text.RegularExpressions;

var regex = new Regex(@"^(\d+): (\d+)$");

var ranges = new Dictionary<int, int>();
var maxDepth = 0;

foreach (var line in File.ReadLines("input.txt")) {
  var groups = regex.Match(line).Groups;
  var depth = Int32.Parse(groups[1].Captures[0].Value);
  ranges.Add(depth, Int32.Parse(groups[2].Captures[0].Value));
  maxDepth = Math.Max(depth, maxDepth);
}

for (var delay = 0;; ++delay) {
  for (var ii = 0; ii <= maxDepth; ++ii) {
    if (ranges.TryGetValue(ii, out var range) && (delay + ii) % (range * 2 - 2) == 0) {
      goto outer;
    }
  }
  Console.WriteLine(delay);
  break;

  outer: ;
}
