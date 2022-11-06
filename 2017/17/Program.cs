const int input = 349;
var next = -1;
var pos = 0;
for (var ii = 1; ii <= 50000000; ++ii) {
  pos = (pos + input) % ii;
  if (pos == 0) next = ii;
  pos = pos + 1;
}

Console.WriteLine(next);
