#include <fstream>
#include <iostream>
#include <string>

int main () {
  std::ifstream in("input.txt");

  int aim = 0;
  int position = 0;
  int depth = 0;

  while (in.good()) {
    std::string line;
    std::getline(in, line);
    auto idx = line.find(' ');
    if (idx == std::string::npos) continue;
    auto command = line.substr(0, idx);
    auto amount = std::stoi(line.substr(idx + 1));
    std::cout << command << " " << amount << std::endl;
    if (command == "forward") {
      position += amount;
      depth += aim * amount;
    } else if (command == "down") aim += amount;
    else if (command == "up") aim -= amount;
    else {
      std::cerr << "Unrecognized command: " << command << std::endl;
    }
  }

  std::cout << position << " " << depth << std::endl;
  std::cout << (position * depth) << std::endl;
}
