Int64 Checksum (string line) {
  var values = line.Split('\t').Select(Int64.Parse).ToArray();
  for (var ii = 0; ii < values.Length; ++ii) {
    for (var jj = 0; jj < values.Length; ++jj) {
      if (ii != jj && values[ii] % values[jj] == 0) return values[ii] / values[jj];
    }
  }
  throw new ArgumentException("No valid pair in line: " + line);
}

var sum = File
  .ReadAllLines("input.txt")
  .Select(Checksum)
  .Sum();
Console.WriteLine(sum);
