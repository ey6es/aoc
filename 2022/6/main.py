def all_different(input):
  for ii in range(0, len(input) - 1):
    for jj in range(ii + 1, len(input)):
      if input[ii] == input[jj]: return False
  return True

with open('input.txt') as f:
  input = f.readline().strip()
  for ii in range(0, len(input) - 13):
    if all_different(input[ii:ii + 14]):
      print(ii + 14)
      break
