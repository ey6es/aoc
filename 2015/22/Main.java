import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.Comparator;
import java.util.PriorityQueue;

public class Main {
  public static void main (String[] args) throws IOException {
    var lines = Files.lines(Path.of("input.txt")).toList();
    var baseBossHitPoints = Integer.parseInt(lines.get(0).split(" ")[2]);
    var bossDamage = Integer.parseInt(lines.get(1).split(" ")[1]);
    
    var fringe = new PriorityQueue<State>(new Comparator<>() {
      public int compare (State s1, State s2) { return s1.spent - s2.spent; }
    });
    fringe.add(new State(0, 50, 500, baseBossHitPoints, 0, 0, 0));

    while (!fringe.isEmpty()) {
      var top = fringe.poll();
      
      var bossHitPoints = top.bossHitPoints;
      if (bossHitPoints <= 0) {
        System.out.println(top.spent);
        break;
      }

      var hp = top.hp - 1;
      if (hp == 0) continue;

      var armor = (top.shield > 1) ? 7 : 0;

      if (top.poison > 0 && (bossHitPoints -= 3) <= 0) {
        System.out.println(top.spent);
        break;
      }

      var mana = top.mana + (top.recharge > 0 ? 101 : 0);

      if (mana >= 53) {
        var nextBossHitPoints = bossHitPoints;
        var nextMana = mana;
        var nextHp = hp;
        if ((nextBossHitPoints -= 4) > 0) {
          if (top.poison > 1) nextBossHitPoints -= 3;
          if (top.recharge > 1) nextMana += 101;
          if (nextBossHitPoints > 0) nextHp -= Math.max(1, bossDamage - armor);
        }
        if (nextHp > 0) {
          fringe.add(new State(top.spent + 53, nextHp, nextMana - 53, nextBossHitPoints,
            Math.max(0, top.shield - 2), Math.max(0, top.poison - 2), Math.max(0, top.recharge - 2)));
        }
      }
      if (mana >= 73) {
        var nextBossHitPoints = bossHitPoints;
        var nextMana = mana;
        var nextHp = hp + 2;
        if ((nextBossHitPoints -= 2) > 0) {
          if (top.poison > 1) nextBossHitPoints -= 3;
          if (top.recharge > 1) nextMana += 101;
          if (nextBossHitPoints > 0) nextHp -= Math.max(1, bossDamage - armor);
        }
        if (nextHp > 0) {
          fringe.add(new State(top.spent + 73, nextHp, nextMana - 73, nextBossHitPoints,
            Math.max(0, top.shield - 2), Math.max(0, top.poison - 2), Math.max(0, top.recharge - 2)));
        }
      }
      if (mana >= 113 && top.shield <= 1) {
        var nextBossHitPoints = bossHitPoints;
        var nextMana = mana;
        var nextHp = hp;
        if (top.poison > 1) nextBossHitPoints -= 3;
        if (top.recharge > 1) nextMana += 101;
        if (nextBossHitPoints > 0) nextHp -= Math.max(1, bossDamage - 7);
        if (nextHp > 0) {
          fringe.add(new State(top.spent + 113, nextHp, nextMana - 113, nextBossHitPoints,
            5, Math.max(0, top.poison - 2), Math.max(0, top.recharge - 2)));
        }
      }
      if (mana >= 173 && top.poison <= 1) {
        var nextBossHitPoints = bossHitPoints - 3;
        var nextMana = mana;
        var nextHp = hp;
        if (top.recharge > 1) nextMana += 101;
        if (nextBossHitPoints > 0) nextHp -= Math.max(1, bossDamage - armor);
        if (nextHp > 0) {
          fringe.add(new State(top.spent + 173, nextHp, nextMana - 173, nextBossHitPoints,
            Math.max(0, top.shield - 2), 5, Math.max(0, top.recharge - 2)));
        }
      }
      if (mana >= 229 && top.recharge <= 1) {
        var nextBossHitPoints = bossHitPoints;
        var nextMana = mana + 101;
        var nextHp = hp;
        if (top.poison > 1) nextBossHitPoints -= 3;
        if (nextBossHitPoints > 0) nextHp -= Math.max(1, bossDamage - armor);
        if (nextHp > 0) {
          fringe.add(new State(top.spent + 229, nextHp, nextMana - 229, nextBossHitPoints,
            Math.max(0, top.shield - 2), Math.max(0, top.poison - 2), 4));
        }
      }
    }
  }

  record State (int spent, int hp, int mana, int bossHitPoints, int shield, int poison, int recharge) {}
}