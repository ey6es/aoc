using System.Text.RegularExpressions;

var regex = new Regex(@"^(\w+) \((\d+)\)(?: -> (?:(\w+)(?:, )?)+)?$");
var nodes = new Dictionary<string, Node>();
foreach (var line in File.ReadLines("input.txt")) {
  var groups = regex.Match(line).Groups;
  nodes.Add(groups[1].Captures[0].Value, new Node(groups));
}

var remaining = nodes.Keys.ToHashSet();
foreach (var node in nodes.Values) {
  foreach (var name in node.above) remaining.Remove(name);
}

nodes[remaining.First()].GetTotalWeight(nodes);

class Node {
  public readonly int weight;
  public readonly string[] above;

  public Node (GroupCollection groups) {
    weight = Int32.Parse(groups[2].Captures[0].Value);
    above = groups[3].Captures.Select(c => c.Value).ToArray();
  }

  public int GetTotalWeight (Dictionary<string, Node> nodes) {
    var aboveWeights = above.Select(name => nodes[name].GetTotalWeight(nodes)).ToArray();
    if (aboveWeights.Distinct().Count() > 1) {
      for (var ii = 0; ii < aboveWeights.Length; ++ii) {
        var aboveWeight = aboveWeights[ii];
        if (aboveWeights.Count(w => w == aboveWeight) == 1) {
          var delta = aboveWeights[(ii + 1) % aboveWeights.Length] - aboveWeight;
          Console.WriteLine(nodes[above[ii]].weight + delta);
          aboveWeights[ii] += delta;
        }
      }
    }

    return weight + aboveWeights.Sum();
  }
}
