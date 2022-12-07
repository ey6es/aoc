class Directory:
  def __init__(self, parent):
    self.files = {}
    self.dirs = {}
    self.parent = parent
  def get_directory(self, name):
    if name == '..': return self.parent
    if not name in self.dirs: self.dirs[name] = Directory(self)
    return self.dirs[name]
  def add_file(self, name, size):
    self.files[name] = size
  def get_smallest_required(self, required):
    smallest = None
    if self.total >= required: smallest = self.total
    for dir in self.dirs.values():
      dir_smallest = dir.get_smallest_required(required)
      if dir_smallest != None: smallest = min(smallest, dir_smallest)
    return smallest
  def get_total_size(self):
    self.total = 0
    for dir in self.dirs.values(): self.total += dir.get_total_size()
    for size in self.files.values(): self.total += size
    return self.total
    
with open('input.txt') as f:
  root = Directory(None)
  current = root
  for line in map(str.strip, f.readlines()):
    if line[0] == '$':
      if line[2] == 'c':
        name = line.split()[2]
        if name == '/': current = root
        else: current = current.get_directory(name)
    else:
      parts = line.split()
      if parts[0] != 'dir': current.add_file(parts[1], int(parts[0]))
  unused = 70000000 - root.get_total_size()
  required = 30000000 - unused
  print(root.get_smallest_required(required))