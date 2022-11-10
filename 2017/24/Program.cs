(int, int) ParseLine (string line) {
  var idx = line.IndexOf('/');
  return (int.Parse(line.Substring(0, idx)), int.Parse(line.Substring(idx + 1)));
}

var comps = File.ReadLines("input.txt").Select(ParseLine).ToArray();
var ports = new Dictionary<int, List<int>>();

void Insert (int port, int index) {
  if (ports.TryGetValue(port, out var list)) list.Add(index);
  else ports[port] = new List<int>(new[] {index});
}

for (var ii = 0; ii < comps.Length; ++ii) {
  var comp = comps[ii];
  Insert(comp.Item1, ii);
  Insert(comp.Item2, ii);
}

var maxLength = 0;
var maxStrength = 0;
void FindMaxBridge (int port, long taken, int length, int strength) {
  if (length > maxLength || length == maxLength && strength > maxStrength) {
    maxLength = length;
    maxStrength = strength;
  }
  if (ports.TryGetValue(port, out var options)) {
    foreach (var option in options) {
      var flag = 1L << option;
      if ((taken & flag) == 0) {
        var comp = comps[option];
        var other = (comp.Item1 == port) ? comp.Item2 : comp.Item1;
        FindMaxBridge(other, taken | flag, length + 1, strength + port + other);
      }
    }
  }
}

FindMaxBridge(0, 0, 0, 0);
Console.WriteLine(maxStrength);
