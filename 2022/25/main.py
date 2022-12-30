total = 0

with open('input.txt') as f:
  for line in map(str.strip, f.readlines()):
    for ii in range(0, len(line)):
      value = 0
      if line[ii] == '-': value = -1
      elif line[ii] == '=': value = -2
      else: value = ord(line[ii]) - ord('0')
      total += value * 5 ** (len(line) - ii - 1)

result = ''
while total > 0:
  value = total % 5
  if value == 3:
    result = '=' + result
    total += 5
  elif value == 4:
    result = '-' + result
    total += 5 
  else: result = str(value) + result
  total //= 5

print(result)