#include <cctype>
#include <fstream>
#include <iostream>
#include <memory>
#include <queue>
#include <stack>
#include <string>
#include <unordered_map>

struct Path {
  std::string node;
  bool visited_small;
  std::shared_ptr<Path> previous;
};

bool all_upper (const std::string& str) {
  for (auto ch : str) {
    if (!std::isupper(ch)) return false;
  }
  return true;
}

int main () {
  std::ifstream in("input.txt");

  std::unordered_multimap<std::string, std::string> connections;

  while (in.good()) {
    std::string line;
    std::getline(in, line);

    auto idx = line.find('-');
    if (idx == std::string::npos) break;

    auto from = line.substr(0, idx);
    auto to = line.substr(idx + 1);

    connections.insert({ {from, to}, {to, from} });
  }

  std::queue<std::shared_ptr<Path>> open_paths;

  open_paths.push(std::shared_ptr<Path>(new Path { "start", false, nullptr }));

  int total = 0;
  while (!open_paths.empty()) {
    auto path = open_paths.front();
    open_paths.pop();

    auto range = connections.equal_range(path->node);
    for (auto it = range.first; it != range.second; it++) {
      auto& dest = it->second;
      // std::cout << path->node << "-" << dest << std::endl;

      if (dest == "start") continue;
      else if (dest == "end") {
        std::stack<std::string> nodes;
        nodes.push(dest);
        for (auto element = path; element; element = element->previous) {
          nodes.push(element->node);
        }
        while (!nodes.empty()) {
          std::cout << "-" << nodes.top();
          nodes.pop();
        }
        std::cout << std::endl;
        total++;
        continue;
      }

      bool visited_small = path->visited_small;
      if (!all_upper(dest)) {
        for (auto element = path; element; element = element->previous) {
          if (element->node == dest) {
            if (visited_small) goto end;
            visited_small = true;
            break;
          }
        }
      }
      open_paths.push(std::shared_ptr<Path>(
        new Path { dest, visited_small, path }));

      end: ;
    }
    std::cout << std::endl;
  }

  std::cout << total << std::endl;
}
