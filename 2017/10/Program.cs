var list = Enumerable.Range(0, 256).ToArray();
var pos = 0;
var skipSize = 0;
var lengths = File.ReadAllText("input.txt").Trim().Select(c => (int)c).Concat(new[] {17, 31, 73, 47, 23});

for (var round = 0; round < 64; ++round) {
  foreach (var length in lengths) {
    for (int ii = 0, ll = length / 2; ii < ll; ++ii) {
      var i0 = (pos + ii) % list.Length;
      var i1 = (pos + length - ii - 1) % list.Length;
      var tmp = list[i0];
      list[i0] = list[i1];
      list[i1] = tmp;
    }

    pos += length + skipSize;
    skipSize++;
  }
}

string ToHexString (int value) {
  var str = Convert.ToString(value, 16);
  return (str.Length == 2) ? str : ("0" + str);
}

var hash = list
  .Chunk(16)
  .Select(c => ToHexString(c.Aggregate((acc, src) => acc ^ src)))
  .Aggregate((acc, src) => acc + src);

Console.WriteLine(hash);
