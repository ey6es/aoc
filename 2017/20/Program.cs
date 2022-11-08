using System.Text.RegularExpressions;

var regex = new Regex(@"^p=<(-?\d+),(-?\d+),(-?\d+)>, v=<(-?\d+),(-?\d+),(-?\d+)>, a=<(-?\d+),(-?\d+),(-?\d+)>$");

Particle ParseParticle (string line) {
  return new Particle(regex.Match(line).Groups);
}

var particles = new LinkedList<Particle>(File.ReadLines("input.txt").Select(ParseParticle));

while (true) {
  var positions = new Dictionary<(long, long, long), LinkedListNode<Particle>>();
  for (var node = particles.First; node != null; ) {
    node.Value.Tick();
    var nextNode = node.Next;
    if (positions.TryGetValue(node.Value.p, out var other)) {
      if (other.List == particles) particles.Remove(other);
      particles.Remove(node);

    } else positions[node.Value.p] = node;
    node = nextNode;
  }
  Console.WriteLine(particles.Count);
}

class Particle {
  public (long x, long y, long z) p;
  public (long x, long y, long z) v;
  public (long x, long y, long z) a;

  public Particle (GroupCollection g) {
    p = (long.Parse(g[1].Captures[0].Value), long.Parse(g[2].Captures[0].Value), long.Parse(g[3].Captures[0].Value));
    v = (long.Parse(g[4].Captures[0].Value), long.Parse(g[5].Captures[0].Value), long.Parse(g[6].Captures[0].Value));
    a = (long.Parse(g[7].Captures[0].Value), long.Parse(g[8].Captures[0].Value), long.Parse(g[9].Captures[0].Value));
  }

  public void Tick () {
    Add(ref v, a);
    Add(ref p, v);
  }

  public long ManhattanDistance () {
    return Math.Abs(p.x) + Math.Abs(p.y) + Math.Abs(p.z);
  }

  public override string ToString () {
    return $"{p} {v} {a}";
  }

  private static void Add (ref (long x, long y, long z) a, (long x, long y, long z) b) {
    a.x += b.x;
    a.y += b.y;
    a.z += b.z;
  }
}
