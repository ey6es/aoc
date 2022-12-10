with open('input.txt') as f:
  cycle = 0
  x = 1
  rows = []
  def add_pixel():
    col = (cycle - 1) % 40
    if col == 0: rows.append('')
    rows[-1] += '#' if abs(x - col) <= 1 else '.'
  for line in map(str.strip, f.readlines()):
    cycle += 1
    add_pixel()
    if line != 'noop':
      cycle += 1
      add_pixel()
      x += int(line.split()[1])
  for row in rows: print(row)

    
  