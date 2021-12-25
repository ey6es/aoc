#include <fstream>
#include <iostream>
#include <limits>
#include <string>

int main () {
  std::ifstream in("input.txt");

  int p0, p1, p2;
  in >> p0;
  in >> p1;
  in >> p2;

  int last_sum = p0 + p1 + p2;
  int greater_count = 0;

  while (in.good()) {
    int value;
    in >> value;
    if (!in.fail()) {
      int sum = last_sum - p0 + value;

      p0 = p1;
      p1 = p2;
      p2 = value;

      if (sum > last_sum) greater_count++;
      last_sum = sum;
    }
  }
  std::cout << greater_count << std::endl;
}
