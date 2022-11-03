int CountGarbage (IEnumerator<Char> it) {
  int count = 0;
  while (it.MoveNext()) {
    switch (it.Current) {
      case '<':
        while (it.MoveNext() && it.Current != '>') {
          if (it.Current == '!') it.MoveNext();
          else count++;
        }
        break;

      case '{':
        count += CountGarbage(it);
        break;

      case '}':
        return count;
    }
  }
  return count;
}

Console.WriteLine(CountGarbage(File.ReadAllText("input.txt").GetEnumerator()));
