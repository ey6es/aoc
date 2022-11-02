var offsets = File.ReadAllLines("input.txt").Select(Int32.Parse).ToArray();
var steps = 0;
for (int ii = 0; ii >= 0 && ii < offsets.Length; ++steps) {
  var offset = offsets[ii];
  offsets[ii] += (offset >= 3) ? -1 : +1;
  ii += offset;
}
Console.WriteLine(steps);
