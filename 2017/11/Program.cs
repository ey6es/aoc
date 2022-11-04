int GetDistance ((int, int) pos) {
  int GetEstimatedDistance ((int x, int y) a, (int x, int y) b) {
    return Math.Abs(a.x - b.x) + Math.Abs(a.y - b.y);
  }

  var fringe = new PriorityQueue<((int, int), int), int>();
  var visited = new HashSet<(int, int)>();

  fringe.Enqueue(((0, 0), 0), GetEstimatedDistance((0, 0), pos));

  while (fringe.Count > 0) {
    var ((x, y), dist) = fringe.Dequeue();

    if ((x, y).Equals(pos)) {
      return dist;
    }

    visited.Add((x, y));

    var sy = x & 1;
    var ny = sy - 1;
    foreach (var neighbor in new[] {(x, y - 1), (x, y + 1), (x - 1, y + ny), (x - 1, y + sy), (x + 1, y + ny), (x + 1, y + sy)}) {
      if (!visited.Contains(neighbor)) {
        var neighborDist = dist + 1;
        fringe.Enqueue((neighbor, neighborDist), neighborDist + GetEstimatedDistance(neighbor, pos));
      }
    }
  }
  return Int32.MaxValue;
}

(int x, int y) pos = (0, 0);
int maxDist = 0;

foreach (var dir in File.ReadLines("input.txt").First().Split(',')) {
  switch (dir) {
    case "n":
      pos.y--;
      break;

    case "s":
      pos.y++;
      break;

    case "nw":
      pos.x--;
      pos.y -= 1 - (pos.x & 1);
      break;

    case "sw":
      pos.x--;
      pos.y += (pos.x & 1);
      break;

    case "ne":
      pos.x++;
      pos.y -= 1 - (pos.x & 1);
      break;

    case "se":
      pos.x++;
      pos.y += (pos.x & 1);
      break;
  }
  maxDist = Math.Max(maxDist, GetDistance(pos));
}

Console.WriteLine(maxDist);
