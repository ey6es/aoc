using System.Collections;

BitArray GetKnotHash (string input) {
  var list = Enumerable.Range(0, 256).ToArray();
  var pos = 0;
  var skipSize = 0;
  var lengths = input.Select(c => (int)c).Concat(new [] {17, 31, 73, 47, 23});

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

  return new BitArray(list
    .Chunk(16)
    .Select(c => c.Aggregate((byte)0, (acc, src) => (byte)(acc ^ src)))
    .Reverse()
    .ToArray());
}

const string input = "amgozmfv";
var data = Enumerable
  .Range(0, 128)
  .Select(ii => GetKnotHash($"{input}-{ii}"))
  .ToArray();

bool Erase (int row, int col) {
  if (row < 0 || col < 0 || row >= 128 || col >= 128 || !data[row][col]) return false;
  data[row][col] = false;
  Erase(row - 1, col);
  Erase(row, col - 1);
  Erase(row, col + 1);
  Erase(row + 1, col);
  return true;
}

var count = 0;
for (var row = 0; row < 128; ++row) {
  for (var col = 0; col < 128; ++col) {
    if (Erase(row, col)) ++count;
  }
}

Console.WriteLine(count);
