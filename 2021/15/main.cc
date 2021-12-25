#include <algorithm>
#include <fstream>
#include <functional>
#include <iostream>
#include <limits>
#include <string>
#include <queue>
#include <unordered_set>
#include <vector>

struct Point {
  int row, col;

  bool operator== (const Point& other) const {
    return row == other.row && col == other.col;
  }
};

template<>
struct std::hash<Point> {
  size_t operator() (const Point& point) const {
    return point.row * 127 + point.col;
  }
};

struct Path {
  Point point;
  int total_risk;
  int estimated_risk;

  bool operator< (const Path& other) const {
    return estimated_risk > other.estimated_risk;
  }
};

int main () {
  std::ifstream in("input.txt");

  std::vector<std::string> map;
  while (in.good()) {
    std::string row;
    std::getline(in, row);

    if (!row.empty()) map.push_back(row);
  }

  int base_rows = map.size();
  int base_cols = map[0].size();

  int rows = base_rows * 5;
  int cols = base_cols * 5;

  int dest_row = rows - 1;
  int dest_col = cols - 1;

  auto get_risk = [&](int row, int col) {
    return (((map[row % base_rows][col % base_cols] - '1') +
      (row / base_rows + col / base_cols)) % 9) + 1;
  };

  std::priority_queue<Path> fringe;
  fringe.push({});

  std::unordered_set<Point> visited;

  auto maybe_push = [&](int row, int col, int previous_risk) {
    if (row < 0 || col < 0 || row >= rows || col >= cols) return;
    if (visited.count({row, col})) return;
    int total_risk = previous_risk + get_risk(row, col);
    int dist = std::abs(row - dest_row) + std::abs(col - dest_col);
    fringe.push({{row, col}, total_risk, total_risk + dist});
  };

  while (!fringe.empty()) {
    Path path = fringe.top();
    fringe.pop();

    visited.insert(path.point);

    if (path.point.row == dest_row && path.point.col == dest_col) {
      std::cout << path.total_risk << std::endl;
      return 0;
    }

    maybe_push(path.point.row - 1, path.point.col, path.total_risk);
    maybe_push(path.point.row + 1, path.point.col, path.total_risk);
    maybe_push(path.point.row, path.point.col - 1, path.total_risk);
    maybe_push(path.point.row, path.point.col + 1, path.total_risk);
  }
}
