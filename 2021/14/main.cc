#include <algorithm>
#include <fstream>
#include <iostream>
#include <limits>
#include <string>
#include <unordered_map>

int main () {
  std::ifstream in("input.txt");

  std::string elements;
  std::getline(in, elements);

  std::string line;
  std::getline(in, line);

  std::unordered_map<std::string, long long> counts;
  for (int i = 0; i < elements.size() - 1; i++) {
    counts[elements.substr(i, 2)]++;
  }

  std::unordered_map<char, long long> element_counts;
  for (char element : elements) {
    element_counts[element]++;
  }

  std::unordered_map<std::string, char> rules;

  while (in.good()) {
    std::getline(in, line);

    if (line.size() > 0) {
      rules[line.substr(0, 2)] = line[6];
    }
  }

  for (int i = 0; i < 40; i++) {
    std::unordered_map<std::string, long long> next_counts;

    for (auto& count : counts) {
      char insert = rules.at(count.first);

      next_counts[std::string() + count.first[0] + insert] += count.second;
      next_counts[std::string() + insert + count.first[1]] += count.second;
      element_counts[insert] += count.second;
    }

    counts = next_counts;
  }

  long long min = std::numeric_limits<long long>().max();
  long long max = std::numeric_limits<long long>().min();
  for (auto& count : element_counts) {
    min = std::min(min, count.second);
    max = std::max(max, count.second);
  }

  std::cout << max << std::endl;
  std::cout << min << std::endl;
  std::cout << (max - min) << std::endl;
}
