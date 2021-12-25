#include <algorithm>
#include <fstream>
#include <iostream>
#include <stack>
#include <vector>

#include <string>

int main () {
  std::ifstream in("input.txt");

  std::vector<long long> scores;

  int total = 0;
  while (in.good()) {
    std::string line;
    std::getline(in, line);

    std::stack<char> stack;
    long long score = 0;

    for (auto ch : line) {
      switch (ch) {
        case '(':
        case '[':
        case '{':
        case '<':
          stack.push(ch);
          break;

        case ')':
          if (stack.top() == '(') stack.pop();
          else {
            total += 3;
            goto end;
          }
          break;

        case ']':
          if (stack.top() == '[') stack.pop();
          else {
            total += 57;
            goto end;
          }
          break;

        case '}':
          if (stack.top() == '{') stack.pop();
          else {
            total += 1197;
            goto end;
          }
          break;

        case '>':
          if (stack.top() == '<') stack.pop();
          else {
            total += 25137;
            goto end;
          }
          break;
      }
    }
    if (stack.empty()) {
      goto end;
    }

    while (!stack.empty()) {
      score *= 5;
      switch (stack.top()) {
        case '(':
          score += 1;
          break;

        case '[':
          score += 2;
          break;

        case '{':
          score += 3;
          break;

        case '<':
          score += 4;
          break;
      }
      stack.pop();
    }
    scores.push_back(score);

    end: ;
  }

  std::sort(scores.begin(), scores.end());

  std::cout << scores[scores.size() / 2] << std::endl;
}
