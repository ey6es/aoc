using System.Text.RegularExpressions;

var regex = new Regex(@"^(\w+) (\w+) (-?\d+) if (\w+) (\S+) (-?\d+)$");

var instructions = File
  .ReadLines("input.txt")
  .Select(l => new Instruction(regex.Match(l).Groups))
  .ToArray();

var registers = new Dictionary<string, int>();

var highestValue = 0;
foreach (var instruction in instructions) {
  instruction.Execute(registers, ref highestValue);
}

Console.WriteLine(highestValue);

enum ComparisonType {
  Equal,
  NotEqual,
  Greater,
  Less,
  GreaterEqual,
  LessEqual
}

readonly struct Instruction {
  public Instruction (GroupCollection groups) {
    Target = groups[1].Captures[0].Value;
    Increment = (groups[2].Captures[0].Value.Equals("dec") ? -1 : 1) * Int32.Parse(groups[3].Captures[0].Value);
    Source = groups[4].Captures[0].Value;

    var ct = groups[5].Captures[0].Value;
    if (ct.Equals("==")) Comparison = ComparisonType.Equal;
    else if (ct.Equals("!=")) Comparison = ComparisonType.NotEqual;
    else if (ct.Equals(">")) Comparison = ComparisonType.Greater;
    else if (ct.Equals("<")) Comparison = ComparisonType.Less;
    else if (ct.Equals(">=")) Comparison = ComparisonType.GreaterEqual;
    else if (ct.Equals("<=")) Comparison = ComparisonType.LessEqual;
    else throw new ArgumentException("Unknown comparison type: " + ct);

    Reference = Int32.Parse(groups[6].Captures[0].Value);
  }

  public string Target { get; init; }
  public int Increment { get; init; }
  public string Source { get; init; }
  public ComparisonType Comparison { get; init; }
  public int Reference { get; init; }

  public override string ToString () => $"{Target} {Increment} {Source} {Comparison} {Reference}";

  public void Execute (Dictionary<string, int> registers, ref int highestValue) {
    var sourceValue = 0;
    registers.TryGetValue(Source, out sourceValue);
    if (!Compare(sourceValue)) return;

    var targetValue = 0;
    registers.TryGetValue(Target, out targetValue);
    targetValue += Increment;
    registers[Target] = targetValue;
    highestValue = Math.Max(targetValue, highestValue);
  }

  private bool Compare (int value) {
    switch (Comparison) {
      case ComparisonType.Equal: return value == Reference;
      case ComparisonType.NotEqual: return value != Reference;
      case ComparisonType.Greater: return value > Reference;
      case ComparisonType.Less: return value < Reference;
      case ComparisonType.GreaterEqual: return value >= Reference;
      default: case ComparisonType.LessEqual: return value <= Reference;
    }
  }
}
