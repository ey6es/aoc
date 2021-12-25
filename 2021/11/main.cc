#include <fstream>
#include <functional>
#include <iostream>
#include <string>
#include <set>

int main () {
  std::ifstream in("input.txt");

  int states[10][10];
  for (int row = 0; row < 10; row++) {
    std::string line;
    std::getline(in, line);

    for (int col = 0; col < 10; col++) {
      states[row][col] = line[col] - '0';
    }
  }

  int flashes = 0;

  for (int step = 0;; step++) {
    std::set<std::tuple<int, int>> will_flash;

    auto increment = [&](int row, int col) {
      if (row < 0 || row > 9 || col < 0 || col > 9) return;
      if (++states[row][col] == 10) will_flash.insert(std::make_tuple(row, col));
    };

    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < 10; col++) {
        increment(row, col);
      }
    }

    std::set<std::tuple<int, int>> did_flash;

    while (!will_flash.empty()) {
      auto do_flash = will_flash;
      will_flash = std::set<std::tuple<int, int>>();

      for (auto& point : do_flash) {
        did_flash.insert(point);

        auto row = std::get<0>(point);
        auto col = std::get<1>(point);
        increment(row - 1, col - 1);
        increment(row - 1, col);
        increment(row - 1, col + 1);
        increment(row, col - 1);
        increment(row, col + 1);
        increment(row + 1, col - 1);
        increment(row + 1, col);
        increment(row + 1, col + 1);
      }
    }

    for (auto& point : did_flash) {
      states[std::get<0>(point)][std::get<1>(point)] = 0;
    }

    if (did_flash.size() == 100) {
      std::cout << step << std::endl;
      return 0;
    }
  }
}
