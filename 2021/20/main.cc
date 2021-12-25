#include <bitset>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

int main () {
  std::ifstream in("input.txt");

  std::string line;
  std::getline(in, line);

  std::bitset<512> program;
  for (int i = 0; i < 512; i++) {
    program[i] = (line[i] == '#');
  }

  std::getline(in, line);

  std::vector<std::vector<bool>> image;

  while (in.good()) {
    std::getline(in, line);

    if (line.empty()) break;
    std::vector<bool> row(line.size());

    for (int i = 0; i < row.size(); i++) {
      row[i] = (line[i] == '#');
    }

    image.push_back(row);
  }

  bool reversed = false;
  auto get_pixel = [&](int row, int col) {
    if (row < 0 || col < 0 || row >= image.size() || col >= image[row].size()) {
      return reversed;
    }
    return static_cast<bool>(image[row][col] ^ reversed);
  };

  for (int step = 0; step < 50; step++) {
    std::vector<std::vector<bool>> next_image;
    bool next_reversed = !reversed;

    int new_rows = image.size() + 2;
    int new_cols = image[0].size() + 2;

    for (int row = 0; row < new_rows; row++) {
      std::vector<bool> next_row(new_cols);

      for (int col = 0; col < new_cols; col++) {
        int index =
          (get_pixel(row - 2, col - 2) ? 256 : 0) |
          (get_pixel(row - 2, col - 1) ? 128 : 0) |
          (get_pixel(row - 2, col) ? 64 : 0) |
          (get_pixel(row - 1, col - 2) ? 32 : 0) |
          (get_pixel(row - 1, col - 1) ? 16 : 0) |
          (get_pixel(row - 1, col) ? 8 : 0) |
          (get_pixel(row, col - 2) ? 4 : 0) |
          (get_pixel(row, col - 1) ? 2 : 0) |
          (get_pixel(row, col) ? 1 : 0);
        next_row[col] = program.test(index) ^ next_reversed;
      }

      next_image.push_back(next_row);
    }

    image = next_image;
    reversed = next_reversed;
  }

  int lit = 0;
  for (int row = 0; row < image.size(); row++) {
    for (int col = 0; col < image[row].size(); col++) {
      if (get_pixel(row, col)) lit++;
    }
  }

  std::cout << lit << std::endl;
}
