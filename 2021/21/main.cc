#include <algorithm>
#include <fstream>
#include <iostream>
#include <string>
#include <utility>
#include <vector>

struct State {
  long long counts[10][10][21][21];
};

int main () {
  std::ifstream in("input.txt");

  auto get_position = [&]() {
    std::string line;
    std::getline(in, line);

    auto idx = line.rfind(' ');
    return std::stoi(line.substr(idx + 1));
  };

  std::vector<int> positions {get_position(), get_position()};
  State state {};
  state.counts[positions[0] - 1][positions[1] - 1][0][0] = 1;

  const int kAdvances[][2] =
    {{3, 1}, {4, 3}, {5, 6}, {6, 7}, {7, 6}, {8, 3}, {9, 1}};

  long long win_counts[2] {};
  for (int i = 0; i < 21; i++) {
    State next_state {};

    for (int p0 = 0; p0 < 10; p0++) {
      for (int p1 = 0; p1 < 10; p1++) {
        for (int s0 = 0; s0 < 21; s0++) {
          for (int s1 = 0; s1 < 21; s1++) {
            auto count = state.counts[p0][p1][s0][s1];
            if (count == 0) continue;

            for (auto& a0 : kAdvances) {
              int new_p0 = (p0 + a0[0]) % 10;
              int new_s0 = s0 + new_p0 + 1;

              if (new_s0 >= 21) win_counts[0] += count * a0[1];
              else {
                for (auto& a1 : kAdvances) {
                  int new_p1 = (p1 + a1[0]) % 10;
                  int new_s1 = s1 + new_p1 + 1;

                  auto total = count * a0[1] * a1[1];

                  if (new_s1 >= 21) win_counts[1] += total;
                  else next_state.counts[new_p0][new_p1][new_s0][new_s1] += total;
                }
              }
            }
          }
        }
      }
    }

    state = next_state;
  }

  std::cout << std::max(win_counts[0], win_counts[1]) << std::endl;
}
