import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.PriorityQueue;

public class Main {
  public static void main (String[] args) throws IOException {
    var lines = Files.lines(Path.of("input.txt")).toList();
    var replacements = new ArrayList<Replacement>();
    for (int ii = 0, nn = lines.size() - 2; ii < nn; ++ii) {
      var parts = lines.get(ii).split(" ");
      replacements.add(new Replacement(parts[0], parts[2]));
    }
    var target = lines.get(lines.size() - 1);
    
    var fringe = new PriorityQueue<Element>(new Comparator<Element>() {
      public int compare (Element e1, Element e2) { return e1.estimate - e2.estimate; }
    });
    fringe.add(new Element(target.length() - 1, 0, target));

    while (!fringe.isEmpty()) {
      var top = fringe.poll();
      if (top.molecule.equals("e")) {
        System.out.println(top.steps);
        break;
      }
      for (var replacement : replacements) {
        for (var index = top.molecule.indexOf(replacement.to);
             index != -1;
             index = top.molecule.indexOf(replacement.to, index + replacement.to.length())) {
          var nextMolecule = top.molecule.substring(0, index) + replacement.from +
            top.molecule.substring(index + replacement.to.length());
          fringe.add(new Element(nextMolecule.length() - 1, top.steps + 1, nextMolecule));
        }
      }
    }
  }

  record Replacement(String from, String to) {}
  record Element(int estimate, int steps, String molecule) {}
}