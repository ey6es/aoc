using System.Text.RegularExpressions;

var regex = new Regex(@"^Generator \w starts with (\d+)$");

var values = File.ReadLines("input.txt").Select(l => ulong.Parse(regex.Match(l).Groups[1].Captures[0].Value)).ToArray();

ulong[] factors = {16807, 48271};
ulong[] multiples = {4, 8};

var count = 0;
for (var ii = 0; ii < 5000000; ++ii) {
  for (var jj = 0; jj < 2; ++jj) {
    do {
      values[jj] = (values[jj] * factors[jj]) % 2147483647ul;
    } while (values[jj] % multiples[jj] != 0);
  }

  if ((values[0] & 0xFFFF) == (values[1] & 0xFFFF)) ++count;
}

Console.WriteLine(count);
