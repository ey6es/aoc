using System.Text.RegularExpressions;

var regex = new Regex(@"^(\d+) <-> (?:(\d+)(?:, )?)+$");

var nodes = new Dictionary<int, Node>();

Node GetNode (int id) {
  if (nodes.TryGetValue(id, out var node)) return node;
  return nodes[id] = new Node();
}

foreach (var line in File.ReadLines("input.txt")) {
  var groups = regex.Match(line).Groups;
  var node = GetNode(Int32.Parse(groups[1].Captures[0].Value));
  foreach (Capture capture in groups[2].Captures) {
    node.linked.Add(GetNode(Int32.Parse(capture.Value)));
  }
}

var count = 0;
foreach (var node in nodes.Values) {
  if (!node.visited) {
    count++;
    node.CountConnected();
  }
}

Console.WriteLine(count);

class Node {
  public List<Node> linked = new List<Node>();
  public bool visited;

  public int CountConnected () {
    if (visited) return 0;
    visited = true;
    var count = 1;
    foreach (var node in linked) count += node.CountConnected();
    return count;
  }
}
