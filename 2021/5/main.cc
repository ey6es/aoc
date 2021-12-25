#include <algorithm>
#include <fstream>
#include <iostream>
#include <map>
#include <string>
#include <tuple>

std::tuple<int, int> parse_coord (const std::string& str) {
  auto idx = str.find(',');
  return std::make_tuple(
    std::stoi(str.substr(0, idx)),
    std::stoi(str.substr(idx + 1)));
}

std::ostream& operator<< (std::ostream& out, const std::tuple<int, int>& tuple) {
  return out << std::get<0>(tuple) << " " << std::get<1>(tuple);
}

int main () {
  std::ifstream in("input.txt");

  std::map<std::tuple<int, int>, int> points;

  while (in.good()) {
    std::string line;
    std::getline(in, line);
    if (!in.good()) break;

    auto start = parse_coord(line.substr(0, line.find(' ')));
    auto end = parse_coord(line.substr(line.rfind(' ') + 1));

    auto sx = std::get<0>(start);
    auto sy = std::get<1>(start);
    auto ex = std::get<0>(end);
    auto ey = std::get<1>(end);
    if (sx == ex) { // vertical line
      auto x = sx;
      auto minmax_y = std::minmax(sy, ey);

      for (auto y = minmax_y.first; y <= minmax_y.second; y++) {
        points[std::make_tuple(x, y)]++;
      }

    } else if (sy == ey) { // horizontal
      auto y = sy;
      auto minmax_x = std::minmax(sx, ex);

      for (auto x = minmax_x.first; x <= minmax_x.second; x++) {
        points[std::make_tuple(x, y)]++;
      }
    } else {
      auto dx = ex - sx;
      auto dy = ey - sy;
      
      if (dx == dy) {
        if (dx > 0) {
          for (auto c = 0; c <= dx; c++) {
            points[std::make_tuple(sx + c, sy + c)]++;
          }
        } else {
          for (auto c = dx; c <= 0; c++) {
            points[std::make_tuple(sx + c, sy + c)]++;
          }
        }
      } else if (dx == -dy) {
        if (dx > 0) {
          for (auto c = 0; c <= dx; c++) {
            points[std::make_tuple(sx + c, sy - c)]++;
          }
        } else {
          for (auto c = dx; c <= 0; c++) {
            points[std::make_tuple(sx + c, sy - c)]++;
          }
        }
      }
    }
  }

  int count = 0;
  for (auto& pair : points) {
    if (pair.second >= 2) count++;
  }

  std::cout << count << std::endl;
}
