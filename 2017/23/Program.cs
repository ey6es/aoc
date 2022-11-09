var instance = new Instance(File.ReadLines("input.txt").ToArray());

while (!instance.Execute());

Console.WriteLine(instance.MulCount);

var count = 0;
for (var ii = 109900; ii <= 126900; ii += 17) {
  for (int jj = 2, ll = (int)Math.Sqrt(ii); jj <= ll; ++jj) {
    if (ii % jj == 0) {
      ++count;
      break;
    }
  }
}

Console.WriteLine(count);

class Instance {
  public int MulCount { get; private set; } = 0;

  public Instance (string[] lines) {
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
        case "set": return () => { regs[xReg] = GetY!(); };
        case "sub": return () => { regs[xReg] = GetX() - GetY!(); };
        case "mul": return () => { regs[xReg] = GetX() * GetY!(); ++MulCount; };
        case "jnz": return () => { if (GetX() != 0) pc += GetY!() - 1; };
        default: throw new ArgumentException($"Unknown instruction: {parts[0]}");
      }
    }).ToArray();
  }

  public bool Execute () {
    instructions[pc++]();
    return pc < 0 || pc >= instructions.Length;
  }

  private delegate long GetValue ();
  private delegate void ExecuteInstruction ();

  private ExecuteInstruction[] instructions;
  private Dictionary<char, long> regs = new Dictionary<char, long>();
  private long pc = 0L;
}
