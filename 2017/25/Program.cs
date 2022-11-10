using System.Text.RegularExpressions;

var lines = File.ReadLines("input.txt").ToArray();

var currentState = new Regex(@"^Begin in state (\w)\.$").Match(lines[0]).Groups[1].Captures[0].Value[0] - 'A';

var steps = int.Parse(
  new Regex(@"^Perform a diagnostic checksum after (\d+) steps\.$").Match(lines[1]).Groups[1].Captures[0].Value);

var states = new Dictionary<int, (Rule, Rule)>();

foreach (var set in lines.Skip(3).Chunk(10)) {
  var state = new Regex(@"^In state (\w):$").Match(set[0]).Groups[1].Captures[0].Value[0] - 'A';
  states[state] = (new Rule(set, 1), new Rule(set, 5));
}

var tape = new HashSet<int>();
var pos = 0;
for (var ii = 0; ii < steps; ++ii) {
  var rules = states[currentState];
  var rule = tape.Contains(pos) ? rules.Item2 : rules.Item1;
  if (rule.value == 1) tape.Add(pos);
  else tape.Remove(pos);
  pos += rule.direction;
  currentState = rule.nextState;
}

Console.WriteLine(tape.Count);

class Rule {
  public int value;
  public int direction;
  public int nextState;

  public Rule (string[] lines, int index) {
    value = int.Parse(new Regex(@"^    - Write the value (\d+).$").Match(lines[index + 1]).Groups[1].Captures[0].Value);
    direction = new Regex(
      @"^    - Move one slot to the (\w+)\.$").Match(lines[index + 2]).Groups[1].Captures[0].Value.Equals("left") ? -1 : +1;
    nextState = new Regex(@"^    - Continue with state (\w)\.$").Match(lines[index + 3]).Groups[1].Captures[0].Value[0] - 'A';
  }
}
