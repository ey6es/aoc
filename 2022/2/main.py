with open('input.txt') as f:
  total = 0
  offsets = [2, 0, 1]
  for line in f.readlines():
    opponent = ord(line[0]) - ord('A')
    player = ord(line[2]) - ord('X')
    score = player * 3 + (opponent + offsets[player]) % 3 + 1
    total += score
  print(total)