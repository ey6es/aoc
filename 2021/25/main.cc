#include <fstream>
#include <iostream>
#include <string>
#include <vector>

int main () {
  std::ifstream in("input.txt");

  std::vector<std::string> state;

  while (in.good()) {
    std::string line;
    std::getline(in, line);

    if (line.empty()) continue;
    state.push_back(line);
  }

  int height = state.size();
  int width = state[0].size();

  int steps = 1;
  for (;; steps++) {
    std::vector<std::string> next_state(height, std::string(width, '.'));

    auto moved = false;

    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        auto next_char = state[row][col];
        switch (next_char) {
          case '.':
            if (state[row][(col + width - 1) % width] == '>') {
              next_char = '>';
              moved = true;
            }
            break;

          case '>':
            if (state[row][(col + 1) % width] == '.') {
              next_char = '.';
              moved = true;
            }
            break;
        }
        next_state[row][col] = next_char;
      }
    }

    state = next_state;

    next_state = std::vector<std::string>(height, std::string(width, '.'));

    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        auto next_char = state[row][col];
        switch (next_char) {
          case '.':
            if (state[(row + height - 1) % height][col] == 'v') {
              next_char = 'v';
              moved = true;
            }
            break;

          case 'v':
            if (state[(row + 1) % height][col] == '.') {
              next_char = '.';
              moved = true;
            }
            break;
        }
        next_state[row][col] = next_char;
      }
    }

    if (!moved) break;

    state = next_state;
  }

  std::cout << steps << std::endl;
}
