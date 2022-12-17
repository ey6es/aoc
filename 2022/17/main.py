rocks = [
  ['####'],

  [' # ',
   '###',
   ' # '],

  ['  #',
   '  #',
   '###'],

  ['#',
   '#',
   '#',
   '#'],

  ['##',
   '##'],
]

occupied = set()

def get_rock_pos(rock, pos, xx, yy):
  return (pos[0] + xx, pos[1] + len(rock) - 1 - yy)

def check_blocked(rock, pos):
  for yy in range(0, len(rock)):
    row = rock[yy]
    for xx in range(0, len(row)):
      if row[xx] == '#':
        rock_pos = get_rock_pos(rock, pos, xx, yy)
        if rock_pos[0] < 0 or rock_pos[0] > 6 or rock_pos[1] < 0 or rock_pos in occupied: return True
  return False

with open('input.txt') as f:
  drafts = f.readline().strip()
  draft_index = 0
  rock_type = 0
  
  last_heights = []
  last_deltas = []
  for ii in range(0, len(drafts) * len(rocks)):
    last_heights.append(0)
    last_deltas.append((0, 0, 0))

  height = 0
  extra_height = 0
  step = 0
  while step < 1000000000000:
    if extra_height == 0:
      last_height_index = rock_type * draft_index
      delta = height - last_heights[last_height_index]
      last_heights[last_height_index] = height
      last_delta = last_deltas[last_height_index]
      if last_delta[0] == delta:
        if last_delta[1] > 10:
          period = step - last_delta[2]
          periods = (1000000000000 - step) // period
          extra_height = periods * delta
          step += periods * period
        last_deltas[last_height_index] = (delta, last_delta[1] + 1, step)
      else:
        last_deltas[last_height_index] = (delta, 1, step)

    rock = rocks[rock_type]
    rock_type = (rock_type + 1) % len(rocks)
    pos = (2, height + 3)
    while True:
      draft = drafts[draft_index]
      draft_index = (draft_index + 1) % len(drafts)
      draft_pos = (pos[0] + (-1 if draft == '<' else 1), pos[1])
      if not check_blocked(rock, draft_pos): pos = draft_pos
      fall_pos = (pos[0], pos[1] - 1)
      if check_blocked(rock, fall_pos):
        for yy in range(0, len(rock)):
          row = rock[yy]
          for xx in range(0, len(row)):
            if row[xx] == '#':
              rock_pos = get_rock_pos(rock, pos, xx, yy)
              occupied.add(rock_pos)
              height = max(height, rock_pos[1] + 1)
        break
      else:
        pos = fall_pos
    step += 1
  print(height + extra_height)