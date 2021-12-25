#include <algorithm>
#include <exception>
#include <fstream>
#include <functional>
#include <iostream>
#include <numeric>
#include <string>
#include <vector>

int main () {
  std::ifstream in("input.txt");

  std::string line;
  std::getline(in, line);

  std::vector<bool> bits;
  for (int i = 0; i < line.size(); i++) {
    int digit = std::stoi(line.substr(i, 1), nullptr, 16);
    bits.push_back(digit & 8);
    bits.push_back(digit & 4);
    bits.push_back(digit & 2);
    bits.push_back(digit & 1);
  }

  auto it = bits.begin();

  auto read_bits = [&](int bit_count) {
    int value = 0;
    for (int i = 0; i < bit_count; i++) {
      value = (value << 1) | (*it++);
    }
    return value;
  };

  std::function<long long()> read_packet = [&]() {
    int version = read_bits(3);
    int type_id = read_bits(3);

    if (type_id == 4) {
      int group;
      long long value = 0;
      do {
        group = read_bits(5);
        value = (value << 4) | (group & 15);
      } while (group & 16);
      return value;

    } else {
      int length_type_id = read_bits(1);

      std::vector<long long> values;

      if (length_type_id) {
        int sub_packet_count = read_bits(11);
        for (int i = 0; i < sub_packet_count; i++) {
          values.push_back(read_packet());
        }
      } else {
        int total_length = read_bits(15);
        auto start = it;
        while ((it - start) < total_length) {
          values.push_back(read_packet());
        }
      }

      switch (type_id) {
        case 0:
          return std::accumulate(values.begin(), values.end(), 0LL);

        case 1:
          return std::accumulate(
            values.begin(), values.end(), 1LL, std::multiplies<long long>());

        case 2:
          return *std::min_element(values.begin(), values.end());

        case 3:
          return *std::max_element(values.begin(), values.end());

        case 5:
          return static_cast<long long>(values[0] > values[1]);

        case 6:
          return static_cast<long long>(values[0] < values[1]);

        case 7:
          return static_cast<long long>(values[0] == values[1]);

        default:
          throw std::out_of_range("Unknown type id");
      }
    }
  };

  long long value = read_packet();

  std::cout << value << std::endl;
}
