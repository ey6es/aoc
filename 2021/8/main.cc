#include <fstream>
#include <iostream>
#include <string>
#include <regex>
#include <unordered_map>

int letters_to_code (const std::string& letters) {
  int code = 0;
  for (auto letter : letters) code |= 1 << (letter - 'a');
  return code;
}

int main () {
  std::ifstream in("input.txt");

  std::regex regex("(\\w+) (\\w+) (\\w+) (\\w+) (\\w+) (\\w+) (\\w+) (\\w+) (\\w+) (\\w+) \\| (\\w+) (\\w+) (\\w+) (\\w+)");

  int sum = 0;
  while (in.good()) {
    std::string line;
    std::getline(in, line);

    std::smatch results;
    if (std::regex_match(line, results, regex)) {
      std::unordered_map<int, int> codes_to_digit;
      int one_code = 0;
      int three_code = 0;
      int four_code = 0;
      int nine_code = 0;

      while (codes_to_digit.size() < 10) {
        for (int i = 1; i <= 10; i++) {
          auto& match = results[i];
          auto code = letters_to_code(match);

          switch (match.length()) {
            case 2:
              codes_to_digit[code] = 1;
              one_code = code;
              break;

            case 4:
              codes_to_digit[code] = 4;
              four_code = code;
              break;

            case 5:
              if (one_code != 0 && (code & one_code) == one_code) {
                codes_to_digit[code] = 3;
                three_code = code;
              }
              if (three_code != 0 && code != three_code) {
                auto parts = four_code ^ one_code;
                codes_to_digit[code] = (code & parts) == parts ? 5 : 2;
              }
              break;

            case 3:
              codes_to_digit[code] = 7;
              break;

            case 6:
              if (four_code != 0 && (code & four_code) == four_code) {
                codes_to_digit[code] = 9;
                nine_code = code;
              }
              if (nine_code != 0 && code != nine_code) {
                codes_to_digit[code] = (code & one_code) == one_code ? 0 : 6;
              }
              break;

            case 7:
              codes_to_digit[code] = 8;
              break;
          }
        }
      }

      int value = 0;
      for (int i = 11; i <= 14; i++) {
        value = value * 10 + codes_to_digit.at(letters_to_code(results[i]));
      }
      sum += value;
    }
  }

  std::cout << sum << std::endl;
}
