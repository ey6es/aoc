#include <fstream>
#include <iostream>
#include <string>
#include <unordered_set>

int filter (const std::unordered_multiset<int>& values, bool most_common) {
  auto filtered_values = values;
  int mask = 1 << 11;
  while (filtered_values.size() != 1) {
    int one_count = 0;
    for (auto value : filtered_values) {
      if ((value & mask) != 0) one_count++;
    }
    int zero_count = filtered_values.size() - one_count;
    bool keep_ones = (one_count >= zero_count) == most_common;
    for (auto it = filtered_values.begin(); it != filtered_values.end(); ) {
      auto value = *it;
      if (((value & mask) != 0) != keep_ones) it = filtered_values.erase(it);
      else it++;
    }
    mask >>= 1;
  }
  return *filtered_values.begin();
}

int main () {
  std::ifstream in("input.txt");
  std::unordered_multiset<int> values;

  while (in.good()) {
    std::string line;
    std::getline(in, line);
    if (line.size() > 0) values.insert(std::stoi(line, nullptr, 2));
  }

  int generator_rating = filter(values, true);
  int scrubber_rating = filter(values, false);

  std::cout << generator_rating << " " << scrubber_rating << " " <<
    (generator_rating * scrubber_rating) << std::endl;
}
