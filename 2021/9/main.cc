#include <fstream>
#include <functional>
#include <iostream>
#include <string>
#include <vector>

typedef std::vector<std::string> heightmap;

int main () {
  std::ifstream in("input.txt");

  heightmap map;
  while (in.good()) {
    std::string line;
    std::getline(in, line);

    if (line.size() > 0) map.push_back(line);
  }

  auto is_low_point = [&](int row, int col) {
    auto height = map[row][col];
    return !(
      row != 0 && height >= map[row - 1][col] ||
      col != 0 && height >= map[row][col - 1] ||
      row != map.size() - 1 && height >= map[row + 1][col] ||
      col != map[row].size() - 1 && height >= map[row][col + 1]
    );
  };

  auto get_basin_size = [&](int row, int col) {
    int size = 0;
    std::function<void(int, int)> fill = [&](int row, int col) {
      if (row < 0 || col < 0 || row >= map.size() || col >= map[row].size() ||
        map[row][col] == '9') return;
      size++;
      map[row][col] = '9';
      fill(row - 1, col);
      fill(row, col - 1);
      fill(row + 1, col);
      fill(row, col + 1);
    };
    fill(row, col);
    return size;
  };

  int basin_sizes[3] {};
  for (int row = 0; row < map.size(); row++) {
    for (int col = 0; col < map[row].size(); col++) {
      if (is_low_point(row, col)) {
        auto basin_size = get_basin_size(row, col);

        if (basin_size > basin_sizes[0]) {
          basin_sizes[2] = basin_sizes[1];
          basin_sizes[1] = basin_sizes[0];
          basin_sizes[0] = basin_size;

        } else if (basin_size > basin_sizes[1]) {
          basin_sizes[2] = basin_sizes[1];
          basin_sizes[1] = basin_size;

        } else if (basin_size > basin_sizes[2]) {
          basin_sizes[2] = basin_size;
        }
      }
    }
  }

  std::cout << (basin_sizes[0] * basin_sizes[1] * basin_sizes[2]) << std::endl;
}
