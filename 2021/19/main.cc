#include <algorithm>
#include <exception>
#include <fstream>
#include <functional>
#include <iostream>
#include <list>
#include <numeric>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

struct Point {
  int x, y, z;

  int& operator[] (int index) {
    switch (index) {
      case 0: return x;
      case 1: return y;
      case 2: return z;
      default: throw std::invalid_argument(std::to_string(index));
    }
  }

  Point operator+ (const Point& other) const {
    return {x + other.x, y + other.y, z + other.z};
  }

  Point operator- (const Point& other) const {
    return {x - other.x, y - other.y, z - other.z};
  }

  int dot (const Point& other) const {
    return x * other.x + y * other.y + z * other.z;
  }

  Point cross (const Point& other) const {
    return {
      y * other.z - z * other.y,
      z * other.x - x * other.z,
      x * other.y - y * other.x
    };
  }

  int manhattan_distance (const Point& other) const {
    return std::abs(x - other.x) + std::abs(y - other.y) + std::abs(z - other.z);
  }

  bool operator< (const Point& other) const {
    if (x < other.x) return true;
    else if (x > other.x) return false;

    if (y < other.y) return true;
    else if (y > other.y) return false;

    return z < other.z;
  }

  bool operator== (const Point& other) const {
    return x == other.x && y == other.y && z == other.z;
  }
};

std::ostream& operator<< (std::ostream& out, const Point& point) {
  out << point.x << "," << point.y << "," << point.z;
  return out;
}

struct Orientation {
  Point x, y, z;

  Point rotate (const Point& point) const {
    return {x.dot(point), y.dot(point), z.dot(point)};
  }
};

std::ostream& operator<< (std::ostream& out, const Orientation& orientation) {
  out << orientation.x << " " << orientation.y << " " << orientation.z;
  return out;
}

std::vector<Orientation> create_orientations () {
  std::vector<Orientation> orientations;

  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 2; j++) {
      for (int k = 0; k < 2; k++) {
        for (int l = 0; l < 2; l++) {
          Point x {}, y {};
          x[i] = (j == 0 ? 1 : -1);
          y[(i + k + 1) % 3] = (l == 0) ? 1 : -1;
          orientations.push_back({x, y, x.cross(y)});
        }
      }
    }
  }

  return orientations;
}

Point rotate (const Point& point, int orient) {
  static std::vector<Orientation> orientations = create_orientations();
  return orientations[orient].rotate(point);
}

template<>
struct std::hash<Point> {
  size_t operator() (const Point& point) const {
    return point.x + 127 * (point.y + 127 * point.z);
  }
};

struct Scanner {
  std::vector<Point> beacons;

  Scanner transform (int orient, const Point& translation) const {
    std::vector<Point> transformed_beacons;
    for (auto& beacon : beacons) {
      transformed_beacons.push_back(rotate(beacon, orient) + translation);
    }
    return {transformed_beacons};
  }
};

int main () {
  std::ifstream in("input.txt");

  std::list<Scanner> scanners;

  while (in.good()) {
    std::string line;
    std::getline(in, line);

    if (line.empty()) break;

    Scanner scanner;

    while (true) {
      std::getline(in, line);
      if (line.empty()) break;

      Point beacon;
      auto idx0 = line.find(',');
      auto idx1 = line.rfind(',');
      beacon.x = std::stoi(line.substr(0, idx0));
      beacon.y = std::stoi(line.substr(idx0 + 1, (idx1 - idx0 - 1)));
      beacon.z = std::stoi(line.substr(idx1 + 1));

      scanner.beacons.push_back(beacon);
    }

    scanners.push_back(scanner);
  }

  std::list<Scanner> oriented_scanners;

  oriented_scanners.push_back(scanners.front());
  scanners.pop_front();

  std::vector<Point> translations;
  translations.push_back({0, 0, 0});

  auto oriented_it = oriented_scanners.begin();
  while (!scanners.empty()) {
    auto& oriented_beacons = oriented_it->beacons;
    std::unordered_map<Point, Point> vectors_to_origin;
    std::unordered_set<Point> oriented_beacon_set(
      oriented_beacons.begin(), oriented_beacons.end());
    for (int i = 0; i < oriented_beacons.size() - 1; i++) {
      for (int j = i + 1; j < oriented_beacons.size(); j++) {
        auto minmax = std::minmax(oriented_beacons[i], oriented_beacons[j]);
        vectors_to_origin[minmax.second - minmax.first] = minmax.first;
      }
    }

    for (auto it = scanners.begin(); it != scanners.end(); ) {
      auto& beacons = it->beacons;

      for (int i = 0; i < beacons.size() - 1; i++) {
        for (int j = i + 1; j < beacons.size(); j++) {
          auto& b0 = beacons[i];
          auto& b1 = beacons[j];
          for (int orient = 0; orient < 24; orient++) {
            auto r0 = rotate(b0, orient);
            auto r1 = rotate(b1, orient);
            auto minmax = std::minmax(r0, r1);
            auto origin = vectors_to_origin.find(minmax.second - minmax.first);
            if (origin == vectors_to_origin.end()) continue;

            auto translation = origin->second - (minmax.first == r0 ? r0 : r1);

            int match_count = 0;
            for (auto& beacon : beacons) {
              auto oriented_beacon = rotate(beacon, orient) + translation;
              if (oriented_beacon_set.count(oriented_beacon)) {
                if (++match_count == 12) {
                  translations.push_back(translation);
                  oriented_scanners.push_back(it->transform(orient, translation));
                  scanners.erase(it++);

                  goto next_scanner;
                }
              }
            }
          }
        }
      }

      it++;
      next_scanner: ;
    }

    oriented_it++;
  }

  std::unordered_set<Point> beacons;

  for (auto& scanner : oriented_scanners) {
    for (auto& beacon : scanner.beacons) {
      beacons.insert(beacon);
    }
  }

  std::cout << beacons.size() << std::endl;

  int largest_manhattan_distance = 0;
  for (int i = 0; i < translations.size(); i++) {
    for (int j = 0; j < translations.size(); j++) {
      largest_manhattan_distance = std::max(
        largest_manhattan_distance,
        translations[i].manhattan_distance(translations[j]));
    }
  }

  std::cout << largest_manhattan_distance << std::endl;
}
