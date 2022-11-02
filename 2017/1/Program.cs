var digits = File.ReadAllLines("input.txt").First();
var sum = 0;
var halfLength = digits.Length / 2;
for (var ii = 0; ii < digits.Length; ++ii) {
  var digit = digits[ii];
  if (digit == digits[(ii + halfLength) % digits.Length]) sum += (digit - '0');
}
Console.WriteLine(sum);
