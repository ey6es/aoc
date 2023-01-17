import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.ArrayList;
import java.util.Comparator;

public class Main {
  public static void main (String[] args) throws IOException {
    var lines = Files.lines(Path.of("input.txt")).toList();
    var baseBossHitPoints = Integer.parseInt(lines.get(0).split(" ")[2]);
    var bossDamage = Integer.parseInt(lines.get(1).split(" ")[1]);
    var bossArmor = Integer.parseInt(lines.get(2).split(" ")[1]);

    Item[] weapons = {new Item(8, 4, 0), new Item(10, 5, 0), new Item(25, 6, 0), new Item(40, 7, 0), new Item(74, 8, 0)};
    Item[] armors = {new Item(13, 0, 1), new Item(31, 0, 2), new Item(53, 0, 3), new Item(75, 0, 4), new Item(102, 0, 5)};
    Item[] rings = {new Item(20, 0, 1), new Item(25, 1, 0), new Item(40, 0, 2),
      new Item(50, 2, 0), new Item(80, 0, 3), new Item(100, 3, 0)};
    
    var loadouts = new ArrayList<Item>();
    for (var weapon : weapons) {
      var baseDamage = weapon.damage;
      for (var jj = -1; jj < armors.length; ++jj) {
        var baseArmor = 0;
        var baseCost = weapon.cost;
        if (jj != -1) {
          var armor = armors[jj];
          baseArmor += armor.armor;
          baseCost += armor.cost;
        }
        loadouts.add(new Item(baseCost, baseDamage, baseArmor));

        for (var ring : rings) {
          var ringCost = baseCost + ring.cost;
          var ringDamage = baseDamage + ring.damage;
          var ringArmor = baseArmor + ring.armor;
          loadouts.add(new Item(ringCost, ringDamage, ringArmor));

          for (var otherRing : rings) {
            if (otherRing != ring) {
              loadouts.add(new Item(ringCost + otherRing.cost, ringDamage + otherRing.damage, ringArmor + otherRing.armor));
            }
          }
        }
      }
    }

    loadouts.sort(new Comparator<>() {
      public int compare (Item i1, Item i2) { return i2.cost - i1.cost; }
    });

    for (var loadout : loadouts) {
      var hitPoints = 100;
      var bossHitPoints = baseBossHitPoints;
      var dealt = Math.max(1, loadout.damage - bossArmor);
      var bossDealt = Math.max(1, bossDamage - loadout.armor);
      while (true) {
        if ((bossHitPoints -= dealt) <= 0) break;
        if ((hitPoints -= bossDealt) <= 0) {
          System.out.println(loadout.cost);
          return;
        }
      }
    }
  }

  record Item (int cost, int damage, int armor) {}
}