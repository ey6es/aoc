var input = File.ReadLines("input.txt").ToArray();
var instances = new[] {new Instance(0, input), new Instance(1, input)};
instances[0].Connect(instances[1]);

while (true) {
  if (instances[0].Execute() & instances[1].Execute()) break;
}

Console.WriteLine(instances[1].SendCount);

class Instance {
  public int SendCount { get; private set; } = 0;

  public Instance (int id, string[] lines) {
    regs['p'] = id;

    instructions = lines.Select<string, ExecuteInstruction>(line => {
      var parts = line.Split(' ');

      GetValue ParseGetValue (string arg) {
        var first = arg[0];
        if (first >= 'a' && first <= 'z') return () => regs.TryGetValue(first, out var value) ? value : 0;
        var value = long.Parse(arg);
        return () => value;
      }
      var xReg = parts[1][0];
      var GetX = ParseGetValue(parts[1]);
      var GetY = (parts.Length == 3) ? ParseGetValue(parts[2]) : null;

      switch (parts[0]) {
        case "snd": return () => { output!.Enqueue(GetX()); SendCount++; return false; };
        case "set": return () => { regs[xReg] = GetY!(); return false; };
        case "add": return () => { regs[xReg] = GetX() + GetY!(); return false; };
        case "mul": return () => { regs[xReg] = GetX() * GetY!(); return false; };
        case "mod": return () => { regs[xReg] = GetX() % GetY!(); return false; };
        case "rcv":
          return () => {
            if (input.Count == 0) return true;
            regs[xReg] = input.Dequeue();
            return false;
          };
        case "jgz": return () => { if (GetX() > 0) pc += GetY!() - 1; return false; };
        default: throw new ArgumentException($"Unknown instruction: {parts[0]}");
      }
    }).ToArray();
  }

  public void Connect (Instance other) {
    output = other.input;
    other.output = input;
  }

  public bool Execute () {
    if (pc < 0 || pc >= instructions.Length) return true;
    if (instructions[pc]()) return true;
    ++pc;
    return false;
  }

  private delegate long GetValue ();
  private delegate bool ExecuteInstruction ();

  private ExecuteInstruction[] instructions;
  private Dictionary<char, long> regs = new Dictionary<char, long>();
  private long pc = 0L;
  private Queue<long> input = new Queue<long>();
  private Queue<long>? output;
}
