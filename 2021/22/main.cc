#include <algorithm>
#include <fstream>
#include <functional>
#include <iostream>
#include <list>
#include <regex>
#include <string>
#include <vector>

struct Vector {
  int x, y, z;

  Vector operator- (const Vector& other) const {
    return {x - other.x, y - other.y, z - other.z};
  }

  Vector operator+ (const Vector& other) const {
    return {x + other.x, y + other.y, z + other.z};
  }

  Vector min (const Vector& other) const {
    return {std::min(x, other.x), std::min(y, other.y), std::min(z, other.z)};
  }

  Vector max (const Vector& other) const {
    return {std::max(x, other.x), std::max(y, other.y), std::max(z, other.z)};
  }
};

std::ostream& operator<< (std::ostream& out, const Vector& vector) {
  return out << vector.x << "," << vector.y << "," << vector.z;
}

struct Box {
  Vector min, max;

  std::vector<Box> subtract (const Box& other) const {
    std::vector<Box> results;

    Box bounds[] {
      {min, other.min - Vector {1, 1, 1}},
      {min.max(other.min), max.min(other.max)},
      {other.max + Vector {1, 1, 1}, max}
    };

    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 3; y++) {
        for (int z = 0; z < 3; z++) {
          if (x == 1 && y == 1 && z == 1) continue;

          Box result {
            {bounds[x].min.x, bounds[y].min.y, bounds[z].min.z},
            {bounds[x].max.x, bounds[y].max.y, bounds[z].max.z}
          };

          if (!result.empty()) results.push_back(result);
        }
      }
    }
    return results;
  }

  bool intersects (const Box& other) const {
    return max.x >= other.min.x && min.x <= other.max.x &&
      max.y >= other.min.y && min.y <= other.max.y &&
      max.z >= other.min.z && min.z <= other.max.z;
  }

  bool empty () const {
    return min.x > max.x || min.y > max.y || min.z > max.z;
  }

  long long size () const {
    return (max.x - min.x + 1LL) * (max.y - min.y + 1LL) * (max.z - min.z + 1LL);
  }
};

std::ostream& operator<< (std::ostream& out, const Box& box) {
  return out << box.min << ".." << box.max;
}

std::ostream& operator<< (std::ostream& out, const std::list<Box>& list) {
  for (auto& box : list) out << box << std::endl;
  return out << std::endl;
}

int main () {
  std::ifstream in("input.txt");

  std::regex regex("(on|off) x=(-?\\w+)\\.\\.(-?\\w+),y=(-?\\w+)\\.\\.(-?\\w+),z=(-?\\w+)\\.\\.(-?\\w+)");

  std::list<Box> set_regions;

  std::function<void(bool, const Box&)> set_region;
  set_region = [&](bool value, const Box& region) {
    for (auto it = set_regions.begin(); it != set_regions.end(); it++) {
      auto& current_region = *it;
      if (region.intersects(current_region)) {
        auto new_regions = current_region.subtract(region);
        set_regions.insert(it, new_regions.begin(), new_regions.end());
        set_regions.erase(it);
        set_region(value, region);
        return;
      }
    }
    if (value) set_regions.push_back(region);
  };

  while (in.good()) {
    std::string line;
    std::getline(in, line);

    if (line.empty()) continue;

    std::smatch results;
    std::regex_match(line, results, regex);

    set_region(
      results[1] == "on",
      {
        {std::stoi(results[2]), std::stoi(results[4]), std::stoi(results[6])},
        {std::stoi(results[3]), std::stoi(results[5]), std::stoi(results[7])}
      }
    );
  }

  long long total_size = 0;
  for (auto& box : set_regions) {
    total_size += box.size();
  }

  std::cout << total_size << std::endl;
}
