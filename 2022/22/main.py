deltas = [(0, 1), (1, 0), (0, -1), (-1, 0)]

def matrix_mult(a, b):
  return ((a[0][0] * b[0][0] + a[0][1] * b[1][0] + a[0][2] * b[2][0],  \
           a[0][0] * b[0][1] + a[0][1] * b[1][1] + a[0][2] * b[2][1],  \
           a[0][0] * b[0][2] + a[0][1] * b[1][2] + a[0][2] * b[2][2]), \
          (a[1][0] * b[0][0] + a[1][1] * b[1][0] + a[1][2] * b[2][0],  \
           a[1][0] * b[0][1] + a[1][1] * b[1][1] + a[1][2] * b[2][1],  \
           a[1][0] * b[0][2] + a[1][1] * b[1][2] + a[1][2] * b[2][2]), \
          (a[2][0] * b[0][0] + a[2][1] * b[1][0] + a[2][2] * b[2][0],  \
           a[2][0] * b[0][1] + a[2][1] * b[1][1] + a[2][2] * b[2][1],  \
           a[2][0] * b[0][2] + a[2][1] * b[1][2] + a[2][2] * b[2][2]))

def vector_mult(m, v):
  return ((m[0][0] * v[0] + m[0][1] * v[1] + m[0][2] * v[2]), \
          (m[1][0] * v[0] + m[1][1] * v[1] + m[1][2] * v[2]), \
          (m[2][0] * v[0] + m[2][1] * v[1] + m[2][2] * v[2]))

dir_matrices = [((0, 0, 1), (0, 1, 0), (-1, 0, 0)), \
                ((1, 0, 0), (0, 0, -1), (0, 1, 0)), \
                ((0, 0, -1), (0, 1, 0), (1, 0, 0)), \
                ((1, 0, 0), (0, 0, 1), (0, -1, 0))]

dir_edges = [((1, 1, 1), (1, -1, 1)), ((-1, -1, 1), (1, -1, 1)), ((-1, 1, 1), (-1, -1, 1)), ((-1, 1, 1), (1, 1, 1))]

with open('input.txt') as f:
  faces = []
  adjacent_faces = [[-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1]]
  face_positions = []
  cube_size = 50
  lines = list(f.readlines())
  current_face = 0
  last_row_faces = []
  for ii in range(0, len(lines) - 2, cube_size):
    first_line = lines[ii]
    current_row_faces = []
    last_face = None
    for jj in range(0, len(first_line) - 1, cube_size):
      face_index = jj // cube_size
      if first_line[jj] != ' ':
        face = []
        for kk in range(0, cube_size):
          face.append(lines[ii + kk][jj:jj + cube_size])
        faces.append(face)
        face_positions.append((ii + 1, jj + 1))
        if last_face != None:
          adjacent_faces[current_face][2] = last_face
          adjacent_faces[last_face][0] = current_face
        if face_index < len(last_row_faces):
          last_row_face = last_row_faces[face_index]
          if last_row_face != None:
            adjacent_faces[current_face][3] = last_row_face
            adjacent_faces[last_row_face][1] = current_face
        current_row_faces.append(current_face)
        last_face = current_face
        current_face += 1
      else:
        current_row_faces.append(None)
        last_face = None
    last_row_faces = current_row_faces
  matrices = [((1, 0, 0), (0, 1, 0), (0, 0, 1)), None, None, None, None, None]
  while True:
    have_all_matrices = True
    for ii in range(0, 6):
      if matrices[ii] != None:
        for jj in range(0, 4):
          adjacent_face = adjacent_faces[ii][jj]
          if adjacent_face != -1 and matrices[adjacent_face] == None:
            matrices[adjacent_face] = matrix_mult(matrices[ii], dir_matrices[jj])
      else:
        have_all_matrices = False
    if have_all_matrices: break
  face_edges = []
  edge_faces = {}
  for ii in range(0, 6):
    edges = []
    matrix = matrices[ii]
    for jj in range(0, 4):
      edge = (vector_mult(matrix, dir_edges[jj][0]), vector_mult(matrix, dir_edges[jj][1]))
      edges.append(edge)
      if edge in edge_faces: edge_faces[edge].append((ii, jj))
      else: edge_faces[edge] = [(ii, jj)]
    face_edges.append(edges)
  instructions = lines[len(lines) - 1]
  instructions_length = len(instructions) - 1
  def get_edge_face(edge, excluding):
    for edge_face in edge_faces[edge]:
      if edge_face[0] != excluding: return edge_face
    return None
  pos = (0, 0, 0)
  dir = 0
  index = 0
  while index < instructions_length:
    start = index
    while index < instructions_length and instructions[index].isdigit(): index += 1
    tiles = int(instructions[start:index])
    for ii in range(0, tiles):
      delta = deltas[dir]
      next_pos = (pos[0], pos[1] + delta[0], pos[2] + delta[1])
      face_dir = None
      if next_pos[1] == -1: face_dir = 3
      elif next_pos[1] == cube_size: face_dir = 1
      elif next_pos[2] == -1: face_dir = 2
      elif next_pos[2] == cube_size: face_dir = 0
      next_dir = dir
      if face_dir != None:
        edge = face_edges[pos[0]][face_dir]
        edge_face = get_edge_face(edge, pos[0])
        coord = pos[1] if dir % 2 == 0 else pos[2]
        if edge_face == None:
          edge_face = get_edge_face((edge[1], edge[0]), pos[0])
          coord = cube_size - coord - 1
        if edge_face[1] == 0: next_pos = (edge_face[0], coord, cube_size - 1)
        elif edge_face[1] == 1: next_pos = (edge_face[0], cube_size - 1, coord)
        elif edge_face[1] == 2: next_pos = (edge_face[0], coord, 0)
        else: next_pos = (edge_face[0], 0, coord)
        next_dir = (edge_face[1] + 2) % 4
      if faces[next_pos[0]][next_pos[1]][next_pos[2]] == '#': break
      dir = next_dir
      pos = next_pos
    if index < instructions_length:
      rotation = instructions[index]
      index += 1
      if rotation == 'R': dir = (dir + 1) % 4
      else: dir = (dir + 3) % 4
  face_pos = face_positions[pos[0]]
  print(1000 * (face_pos[0] + pos[1]) + 4 * (face_pos[1] + pos[2]) + dir)
