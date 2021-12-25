#include <algorithm>
#include <fstream>
#include <iostream>
#include <limits>
#include <regex>
#include <string>

struct Point {
  int x, y;

  void min (const Point& p2) {
    x = std::min(x, p2.x);
    y = std::min(y, p2.y);
  }

  void max (const Point& p2) {
    x = std::max(x, p2.x);
    y = std::max(y, p2.y);
  }
};

std::ostream& operator<< (std::ostream& out, const Point& point) {
  return out << "(" << point.x << ", " << point.y << ")";
}

int main () {
  std::ifstream in("input.txt");

  std::string line;
  std::getline(in, line);

  std::regex regex("target area: x=(-?\\w+)\\.\\.(-?\\w+), y=(-?\\w+)\\.\\.(-?\\w+)");

  std::smatch results;
  std::regex_match(line, results, regex);

  Point min {std::stoi(results[1]), std::stoi(results[3])};
  Point max {std::stoi(results[2]), std::stoi(results[4])};

  auto contains = [&](const Point& point) {
    return point.x >= min.x && point.y >= min.y &&
      point.x <= max.x && point.y <= max.y;
  };

  int highest_highest_y = 0;
  Point min_init_vel {std::numeric_limits<int>().max(), std::numeric_limits<int>().max()};
  Point max_init_vel {};
  int count = 0;

  auto simulate = [&](const Point& init_vel) {
    Point pos {};
    Point vel = init_vel;

    int highest_y = 0;

    while (vel.y >= 0 || pos.y >= min.y) {
      pos.x += vel.x;
      pos.y += vel.y;

      highest_y = std::max(pos.y, highest_y);

      if (contains(pos)) {
        highest_highest_y = std::max(highest_y, highest_highest_y);
        min_init_vel.min(init_vel);
        max_init_vel.max(init_vel);
        count++;
        return;
      }

      if (vel.x > 0) vel.x--;
      else if (vel.x < 0) vel.x++;
      vel.y--;
    }
  };

  for (int init_vel_x = -0; init_vel_x < 1000; init_vel_x++) {
    for (int init_vel_y = -1000; init_vel_y < 1000; init_vel_y++) {
      simulate({init_vel_x, init_vel_y});
    }
  }

  std::cout << min_init_vel << " " << max_init_vel << std::endl;
  std::cout << highest_highest_y << std::endl;
  std::cout << count << std::endl;
}
