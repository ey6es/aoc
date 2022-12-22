def update_bots(*args):
  min_bot = 32
  for ii in range(0, len(args), 2):
    bots = args[ii]
    amount = args[ii + 1]
    length = len(bots)
    while amount > 0:
      bot = bots[0]
      max_index = 0
      for jj in range(1, length):
        if bots[jj] != bot: break
        max_index = jj
      min_bot = min(min_bot, bot)
      for jj in range(max_index, -1, -1):
        bots[jj] -= 1
        amount -= 1
        if amount == 0: break
  return min_bot - 2

def get_max_geodes(ore_ore, clay_ore, obsidian_ore, obsidian_clay, geode_ore, geode_obsidian, duration):
  global max_geodes
  max_geodes = 0
  def simulate(ore_bots = [duration], clay_bots = [], obsidian_bots = [], geode_bots = [], last_bot = duration):
    total_ore = sum(ore_bots)
    total_clay = sum(clay_bots)
    total_obsidian = sum(obsidian_bots)
    total_geodes = sum(geode_bots)
    global max_geodes
    if total_geodes > max_geodes:
      max_geodes = total_geodes
    if total_ore >= geode_ore and total_obsidian >= geode_obsidian:
      new_ore_bots = ore_bots.copy()
      new_obsidian_bots = obsidian_bots.copy()
      new_geode_bots = geode_bots.copy()
      bot = update_bots(new_ore_bots, geode_ore, new_obsidian_bots, geode_obsidian)
      if bot > 0 and bot < last_bot:
        new_geode_bots.append(bot)
        simulate(new_ore_bots, clay_bots, new_obsidian_bots, new_geode_bots, bot)
    if total_ore >= obsidian_ore and total_clay >= obsidian_clay:
      new_ore_bots = ore_bots.copy()
      new_clay_bots = clay_bots.copy()
      new_obsidian_bots = obsidian_bots.copy()
      bot = update_bots(new_ore_bots, obsidian_ore, new_clay_bots, obsidian_clay)
      if bot > 2 and bot < last_bot:
        new_obsidian_bots.append(bot)
        simulate(new_ore_bots, new_clay_bots, new_obsidian_bots, geode_bots, bot)
    if total_ore >= clay_ore:
      new_ore_bots = ore_bots.copy()
      new_clay_bots = clay_bots.copy()
      bot = update_bots(new_ore_bots, clay_ore)
      if bot > 2 and bot < last_bot:
        new_clay_bots.append(bot)
        simulate(new_ore_bots, new_clay_bots, obsidian_bots, geode_bots, bot)
    if total_ore >= ore_ore:
      new_ore_bots = ore_bots.copy()
      bot = update_bots(new_ore_bots, ore_ore)
      if bot > 2 and bot < last_bot:
        new_ore_bots.append(bot)
        simulate(new_ore_bots, clay_bots, obsidian_bots, geode_bots, bot)
  simulate()
  return max_geodes

with open('input.txt') as f:
  product = 1
  lines = list(f.readlines())
  for ii in range(0, 3):
    parts = lines[ii].split()
    id = int(parts[1][:-1])
    ore_ore = int(parts[6])
    clay_ore = int(parts[12])
    obsidian_ore = int(parts[18])
    obsidian_clay = int(parts[21])
    geode_ore = int(parts[27])
    geode_obsidian = int(parts[30])
    product *= get_max_geodes(ore_ore, clay_ore, obsidian_ore, obsidian_clay, geode_ore, geode_obsidian, 32)
  print(product)
