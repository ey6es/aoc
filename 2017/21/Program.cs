using System.Collections;
using System.Text.RegularExpressions;

var rules2 = new Dictionary<int, BitArray>();
var rules3 = new Dictionary<int, BitArray>();

var regex = new Regex(@"^([#\.]+)/([#\.]+)(?:/([#\.]+))? => ([#\.]+)/([#\.]+)/([#\.]+)(?:/([#\.]+))?$");

BitArray ParsePattern (string[] patterns) {
  var size = patterns[0].Length;
  var value = new BitArray(size * size);
  for (var row = 0; row < size; ++row) {
    for (var col = 0; col < size; ++col) {
      if (patterns[row][col] == '#') value[row * size + col] = true;
    }
  }
  return value;
}

int FromBitArray (BitArray data) {
  var value = 0;
  foreach (bool element in data) {
    value <<= 1;
    if (element) value |= 1;
  }
  return value;
}

BitArray HFlip (BitArray data) {
  var size = (int)Math.Sqrt(data.Length);
  var newData = new BitArray(data.Length);
  for (var row = 0; row < size; ++row) {
    for (var col = 0; col < size; ++col) {
      newData[row * size + col] = data[row * size + size - col - 1];
    }
  }
  return newData;
}

BitArray VFlip (BitArray data) {
  var size = (int)Math.Sqrt(data.Length);
  var newData = new BitArray(data.Length);
  for (var row = 0; row < size; ++row) {
    for (var col = 0; col < size; ++col) {
      newData[row * size + col] = data[(size - row - 1) * size + col];
    }
  }
  return newData;
}

BitArray Transpose (BitArray data) {
  var size = (int)Math.Sqrt(data.Length);
  var newData = new BitArray(data.Length);
  for (var row = 0; row < size; ++row) {
    for (var col = 0; col < size; ++col) {
      newData[row * size + col] = data[col * size + row];
    }
  }
  return newData;
}

foreach (var line in File.ReadLines("input.txt")) {
  var groups = regex.Match(line).Groups;
  BitArray key, value;
  Dictionary<int, BitArray> rules;
  if (groups[3].Captures.Count == 0) {
    key = ParsePattern(new[] {groups[1].Captures[0].Value, groups[2].Captures[0].Value});
    value = ParsePattern(new[] {groups[4].Captures[0].Value, groups[5].Captures[0].Value, groups[6].Captures[0].Value});
    rules = rules2;

  } else {
    key = ParsePattern(new[] {groups[1].Captures[0].Value, groups[2].Captures[0].Value, groups[3].Captures[0].Value});
    value = ParsePattern(new[] {
      groups[4].Captures[0].Value, groups[5].Captures[0].Value, groups[6].Captures[0].Value, groups[7].Captures[0].Value});
    rules = rules3;
  }
  rules[FromBitArray(key)] = value;
  rules[FromBitArray(HFlip(key))] = value;
  rules[FromBitArray(VFlip(key))] = value;
  rules[FromBitArray(VFlip(HFlip(key)))] = value;
  var transposed = Transpose(key);
  rules[FromBitArray(transposed)] = value;
  rules[FromBitArray(HFlip(transposed))] = value;
  rules[FromBitArray(VFlip(transposed))] = value;
  rules[FromBitArray(VFlip(HFlip(transposed)))] = value;
}

var size = 3;
var data = new BitArray(new[] {false, true, false, false, false, true, true, true, true});

for (var ii = 0; ii < 18; ++ii) {
  var oldSize = size;
  var oldData = data;
  int srcSize;
  Dictionary<int, BitArray> rules;
  if (size % 2 == 0) {
    srcSize = 2;
    rules = rules2;
  } else {
    srcSize = 3;
    rules = rules3;
  }
  var destSize = srcSize + 1;

  size = size * destSize / srcSize;
  data = new BitArray(size * size);
  for (int srcRow = 0, destRow = 0; srcRow < oldSize; srcRow += srcSize, destRow += destSize) {
    for (int srcCol = 0, destCol = 0; srcCol < oldSize; srcCol += srcSize, destCol += destSize) {
      int input = 0;
      for (var yy = 0; yy < srcSize; ++yy) {
        for (var xx = 0; xx < srcSize; ++xx) {
          input <<= 1;
          if (oldData[(srcRow + yy) * oldSize + srcCol + xx]) input |= 1;
        }
      }

      var output = rules[input];
      for (var yy = 0; yy < destSize; ++yy) {
        for (var xx = 0; xx < destSize; ++xx) {
          data[(destRow + yy) * size + destCol + xx] = output[yy * destSize + xx];
        }
      }
    }
  }
}

var count = 0;
foreach (bool value in data) {
  if (value) ++count;
}
Console.WriteLine(count);
