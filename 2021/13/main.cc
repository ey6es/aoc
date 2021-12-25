#include <fstream>
#include <functional>
#include <iostream>
#include <numeric>
#include <string>
#include <unordered_set>

struct Point {
  int x, y;

  bool operator== (const Point& p) const {
    return x == p.x && y == p.y;
  }
};

template<>
struct std::hash<Point> {
  size_t operator() (const Point& p) const {
    return p.x * 127 + p.y;
  }
};

int main () {
  std::ifstream in("input.txt");

  std::unordered_set<Point> points;

  while (true) {
    std::string line;
    std::getline(in, line);

    if (line.size() == 0) break;

    auto idx = line.find(',');
    auto x = std::stoi(line.substr(0, idx));
    auto y = std::stoi(line.substr(idx + 1));

    points.insert({x, y});
  }

  while (in.good()) {
    std::string line;
    std::getline(in, line);
    if (line.size() == 0) break;

    auto idx = line.find('=');
    auto axis = line[idx - 1];
    auto coord = std::stoi(line.substr(idx + 1));

    std::unordered_set<Point> new_points;

    for (auto& point : points) {
      if (axis == 'x') {
        if (point.x <= coord) new_points.insert(point);
        else new_points.insert({2*coord - point.x, point.y});

      } else {
        if (point.y <= coord) new_points.insert(point);
        else new_points.insert({point.x, 2*coord - point.y});
      }
    }

    points = new_points;
  }

  int max_x = 0, max_y = 0;
  for (auto& point : points) {
    max_x = std::max(point.x, max_x);
    max_y = std::max(point.y, max_y);
  }

  for (int y = 0; y <= max_y; y++) {
    for (int x = 0; x <= max_x; x++) {
      std::cout << (points.count({x, y}) ? '#' : '.');
    }
    std::cout << std::endl;
  }

  std::cout << points.size() << std::endl;
}
