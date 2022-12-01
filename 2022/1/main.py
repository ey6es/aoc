with open('input.txt') as f:
  total = 0
  totals = []
  for line in map(str.strip, f.readlines()):
    if line == '':
      totals.append(total)
      total = 0
    else: total += int(line)
  totals.append(total)
  print(sum(sorted(totals)[-3:]))
