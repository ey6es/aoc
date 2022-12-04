with open('input.txt') as f:
  total = 0
  lines = list(map(str.strip, f.readlines()))
  for ii in range(0, len(lines), 3):
    r0 = set(lines[ii])
    r1 = set(lines[ii + 1])
    r2 = set(lines[ii + 2])
    for ch in r0.intersection(r1).intersection(r2):
      if ch.isupper(): total += ord(ch) - ord('A') + 27
      else: total += ord(ch) - ord('a') + 1
  print(total)



