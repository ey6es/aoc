#include <fstream>
#include <iostream>
#include <numeric>
#include <regex>
#include <string>
#include <valarray>

int main () {
  std::ifstream in("input.txt");

  std::string line;
  std::getline(in, line);

  std::regex regex("(\\d+),?");
  std::regex_iterator<std::string::iterator> it(
    line.begin(), line.end(), regex);
  std::regex_iterator<std::string::iterator> end;

  std::valarray<long long> fish(9);

  for (; it != end; it++) {
    fish[std::stoi((*it)[1].str())]++;
  }

  for (int day = 0; day < 256; day++) {
    long long breeding = fish[0];
    fish[0] = fish[1];
    fish[1] = fish[2];
    fish[2] = fish[3];
    fish[3] = fish[4];
    fish[4] = fish[5];
    fish[5] = fish[6];
    fish[6] = fish[7] + breeding;
    fish[7] = fish[8];
    fish[8] = breeding;
  }

  std::cout << std::accumulate(std::begin(fish), std::end(fish), 0LL) << std::endl;
}
