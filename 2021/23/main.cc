#include <bitset>
#include <fstream>
#include <functional>
#include <iostream>
#include <queue>
#include <string>
#include <unordered_map>
#include <unordered_set>

struct Point {
  int x, y;

  bool operator== (const Point& other) const {
    return x == other.x && y == other.y;
  }
};

template<>
struct std::hash<Point> {
  size_t operator() (const Point& point) const {
    return point.x + 127 * point.y;
  }
};

typedef std::bitset<69> State;

struct Plan {
  State state;
  int total_cost;
  int estimated_cost;

  bool operator< (const Plan& other) const {
    return estimated_cost > other.estimated_cost;
  }
};

int main () {
  std::ifstream in("input.txt");

  std::string line;
  std::getline(in, line);
  std::getline(in, line);

  auto get_element = [](const State& state, int pos) {
    int offset = pos * 3;
    return state.test(offset) |
      state.test(offset + 1) << 1 |
      state.test(offset + 2) << 2;
  };

  auto set_element = [&](const State& state, int pos, int value) {
    State new_state = state;
    int offset = pos * 3;
    new_state.set(offset, value & 1);
    new_state.set(offset + 1, value & 2);
    new_state.set(offset + 2, value & 4);
    return new_state;
  };

  State init_state;

  auto set_init_state = [&](char ch, int pos) {
    init_state = set_element(init_state, pos, ch - 'A' + 1);
  };


  std::getline(in, line);
  set_init_state(line[3], 7);
  set_init_state(line[5], 11);
  set_init_state(line[7], 15);
  set_init_state(line[9], 19);

  set_init_state('D', 8);
  set_init_state('C', 12);
  set_init_state('B', 16);
  set_init_state('A', 20);

  set_init_state('D', 9);
  set_init_state('B', 13);
  set_init_state('A', 17);
  set_init_state('C', 21);

  std::getline(in, line);
  set_init_state(line[3], 10);
  set_init_state(line[5], 14);
  set_init_state(line[7], 18);
  set_init_state(line[9], 22);

  State goal_state;
  goal_state = set_element(goal_state, 7, 1);
  goal_state = set_element(goal_state, 8, 1);
  goal_state = set_element(goal_state, 9, 1);
  goal_state = set_element(goal_state, 10, 1);
  goal_state = set_element(goal_state, 11, 2);
  goal_state = set_element(goal_state, 12, 2);
  goal_state = set_element(goal_state, 13, 2);
  goal_state = set_element(goal_state, 14, 2);
  goal_state = set_element(goal_state, 15, 3);
  goal_state = set_element(goal_state, 16, 3);
  goal_state = set_element(goal_state, 17, 3);
  goal_state = set_element(goal_state, 18, 3);
  goal_state = set_element(goal_state, 19, 4);
  goal_state = set_element(goal_state, 20, 4);
  goal_state = set_element(goal_state, 21, 4);
  goal_state = set_element(goal_state, 22, 4);

  std::priority_queue<Plan> fringe;
  fringe.push({init_state});

  std::unordered_set<State> visited;

  const int kCostsPerStep[] {1, 10, 100, 1000};

  const Point kLocations[] {
    {0, 0},
    {1, 0},
    {3, 0},
    {5, 0},
    {7, 0},
    {9, 0},
    {10, 0},
    {2, 1},
    {2, 2},
    {2, 3},
    {2, 4},
    {4, 1},
    {4, 2},
    {4, 3},
    {4, 4},
    {6, 1},
    {6, 2},
    {6, 3},
    {6, 4},
    {8, 1},
    {8, 2},
    {8, 3},
    {8, 4}
  };

  std::unordered_map<Point, int> kPositions;
  for (int pos = 0; pos < 23; pos++) {
    kPositions[kLocations[pos]] = pos;
  }

  const int kRoomPositions[] {7, 11, 15, 19};

  auto heuristic = [&](const State& state) {
    int total = 0;
    for (int pos = 0; pos < 23; pos++) {
      int element = get_element(state, pos);
      if (element == 0) continue;
      auto& location = kLocations[pos];
      auto dest_pos = kRoomPositions[element - 1];
      auto& dest_location = kLocations[dest_pos];

      int distance = 0;
      if (pos < 7) {
        distance = std::abs(location.x - dest_location.x) + 1;

      } else if (location.x != dest_location.x) {
        distance = location.y + std::abs(location.x - dest_location.x) + 1;
      }
      total += distance * kCostsPerStep[element - 1];
    }
    return total;
  };

  auto push_state = [&](const State& state, int total_cost) {
    if (visited.count(state) == 0) {
      fringe.push({state, total_cost, total_cost + heuristic(state)});
    }
  };

  auto hall_clear_between = [&](const State& state, int src_x, int dest_x) {
    int increment = dest_x > src_x ? 1 : -1;
    for (int x = src_x + increment; x != dest_x + increment; x += increment) {
      auto it = kPositions.find({x, 0});
      if (it != kPositions.end() && get_element(state, it->second) != 0) {
        return false;
      }
    }
    return true;
  };

  auto room_clear_above = [&](const State& state, int src_x, int src_y) {
    for (int y = src_y - 1; y > 0; y--) {
      if (get_element(state, kPositions[{src_x, y}]) != 0) return false;
    }
    return true;
  };

  while (!fringe.empty()) {
    Plan plan = fringe.top();
    fringe.pop();

    if (plan.state == goal_state) {
      std::cout << plan.total_cost << std::endl;
      return 0;
    }

    visited.insert(plan.state);

    for (int pos = 0; pos < 23; pos++) {
      int element = get_element(plan.state, pos);
      if (element == 0) continue;
      auto& location = kLocations[pos];
      auto cost_per_step = kCostsPerStep[element - 1];

      State next_state = set_element(plan.state, pos, 0);
      if (pos < 7) {
        auto dest_pos0 = kRoomPositions[element - 1];
        auto& dest_location = kLocations[dest_pos0];

        if (
          get_element(plan.state, dest_pos0) == 0 &&
          hall_clear_between(plan.state, location.x, dest_location.x)
        ) {
          for (int dest_pos = dest_pos0 + 3; dest_pos >= dest_pos0; dest_pos--) {
            auto dest_element = get_element(plan.state, dest_pos);
            if (dest_element == 0) {
              push_state(
                set_element(next_state, dest_pos, element),
                plan.total_cost + (std::abs(location.x - dest_location.x) +
                  kLocations[dest_pos].y) * cost_per_step
              );
            } else if (dest_element != element) break;
          }
        }
      } else if (room_clear_above(plan.state, location.x, location.y)) {
        for (int dest_pos = 0; dest_pos < 7; dest_pos++) {
          auto& dest_location = kLocations[dest_pos];
          if (hall_clear_between(plan.state, location.x, dest_location.x)) {
            push_state(
              set_element(next_state, dest_pos, element),
              plan.total_cost + (std::abs(location.x - dest_location.x) +
                location.y) * cost_per_step
            );
          }
        }
      }
    }
  }
}
