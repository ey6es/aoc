bool IsValid (string line) {
  string SortChars (string element) {
    var chars = element.ToCharArray();
    Array.Sort(chars);
    return new String(chars);
  }
  var elements = line.Split(' ').Select(SortChars);
  return elements.Count() == elements.Distinct().Count();
}

Console.WriteLine(File.ReadAllLines("input.txt").Where(IsValid).Count());
