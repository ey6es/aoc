using System.Collections;

var blocks = File.ReadAllLines("input.txt").First().Split('\t').Select(Int32.Parse).ToArray();
var seen = new HashSet<int[]>(new ArrayEqualityComparer());
int[]? firstRepeated = null;
for (var cycles = 0;; ++cycles) {
  if (firstRepeated != null) {
    if (StructuralComparisons.StructuralEqualityComparer.Equals(blocks, firstRepeated)) {
      Console.WriteLine(cycles);
      break;
    }
  } else if (!seen.Add(blocks)) {
    firstRepeated = blocks;
    cycles = 0;
  }
  blocks = (int[])blocks.Clone();

  int maxIndex = 0, maxValue = -1;
  for (var ii = 0; ii < blocks.Length; ++ii) {
    if (blocks[ii] > maxValue) {
      maxValue = blocks[ii];
      maxIndex = ii;
    }
  }

  blocks[maxIndex] = 0;
  for (; maxValue > 0; --maxValue) {
    blocks[(maxIndex + maxValue) % blocks.Length]++;
  }
}

class ArrayEqualityComparer : IEqualityComparer<int[]> {
  public bool Equals (int[]? a, int[]? b) {
    return StructuralComparisons.StructuralEqualityComparer.Equals(a, b);
  }
  public int GetHashCode (int[]? array) {
    return (array == null) ? 0 : StructuralComparisons.StructuralEqualityComparer.GetHashCode(array);
  }
}
