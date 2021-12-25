#include <cmath>
#include <fstream>
#include <functional>
#include <iostream>
#include <limits>
#include <numeric>
#include <regex>
#include <string>

int main () {
  std::ifstream in("input.txt");

  std::string line;
  std::getline(in, line);

  std::regex regex("(\\d+),?");
  std::regex_iterator<std::string::iterator> it(
    line.begin(), line.end(), regex);
  std::regex_iterator<std::string::iterator> end;

  std::vector<int> positions;
  int min = std::numeric_limits<int>().max();
  int max = std::numeric_limits<int>().min();

  for (; it != end; it++) {
    int position = std::stoi((*it)[1].str());
    positions.push_back(position);
    min = std::min(min, position);
    max = std::max(max, position);
  }

  int min_total_cost = std::numeric_limits<int>().max();

  for (int align = min; align <= max; align++) {
    min_total_cost = std::min(min_total_cost,
      std::accumulate(positions.begin(), positions.end(), 0,
        [=](int total, int position) { int diff = std::abs(position - align); return total + diff*(diff + 1) / 2; }));
  }

  std::cout << min_total_cost << std::endl;
}
