with open('input.txt') as f:
  offsets = list(map(lambda l: int(l) * 811589153, f.readlines()))
  length = len(offsets)
  original_to_current = list(range(0, length))
  current_to_original = original_to_current.copy()
  for ii in range(0, 10):
    for jj in range(0, length):
      offset = offsets[jj]
      count = abs(offset) % (length - 1)
      increment = 1 if offset > 0 else length - 1
      index = original_to_current[jj]
      for kk in range(0, count):
        swap_index = (index + increment) % length
        original = current_to_original[index]
        swap_original = current_to_original[swap_index]
        current_to_original[swap_index] = original
        current_to_original[index] = swap_original
        original_to_current[original] = swap_index
        original_to_current[swap_original] = index
        index = swap_index
  zero_index = original_to_current[offsets.index(0)]
  first = offsets[current_to_original[(zero_index + 1000) % length]]
  second = offsets[current_to_original[(zero_index + 2000) % length]]
  third = offsets[current_to_original[(zero_index + 3000) % length]]
  print(first + second + third)
