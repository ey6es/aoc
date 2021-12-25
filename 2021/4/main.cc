#include <fstream>
#include <iostream>
#include <string>
#include <vector>

std::ostream& operator<< (std::ostream& out, const std::vector<int>& vector) {
  for (auto value : vector) out << value << " ";
  return out;
}

struct Board {
  int values[5][5];
  int win_value = 0;

  bool has_won () const {
    for (int i = 0; i < 5; i++) {
      if (row_wins(i) || col_wins(i)) return true;
    }
    return false;
  }

  bool row_wins (int row) const {
    for (int col = 0; col < 5; col++) {
      if (values[row][col] != 0) return false;
    }
    return true;
  }

  bool col_wins (int col) const {
    for (int row = 0; row < 5; row++) {
      if (values[row][col] != 0) return false;
    }
    return true;
  }

  int unmarked_sum () const {
    int sum = 0;
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        sum += values[row][col];
      }
    }
    return sum;
  }
};

std::ostream& operator<< (std::ostream& out, const Board& board) {
  for (int row = 0; row < 5; row++) {
    for (int col = 0; col < 5; col++) out << board.values[row][col] << " ";
    out << std::endl;
  }
  out << std::endl;
  return out;
}

int main () {
  std::ifstream in("input.txt");

  std::vector<int> calls;
  std::string call_string;
  std::getline(in, call_string);

  for (std::size_t idx = 0;; ) {
    auto comma_idx = call_string.find(',', idx);
    calls.push_back(std::stoi(call_string.substr(
      idx, comma_idx == std::string::npos ? comma_idx : comma_idx - idx)));
    if (comma_idx == std::string::npos) break;
    idx = comma_idx + 1;
  }

  std::vector<Board> boards;

  while (in.good()) {
    std::string line;
    std::getline(in, line);
    if (!in.good()) break;
    Board board;
    for (int row = 0; row < 5; row++) {
      std::getline(in, line);
      for (int col = 0; col < 5; col++) {
        auto number = line.substr(col * 3, 2);
        if (number[0] == ' ') number[0] = '0';
        board.values[row][col] = std::stoi(number);
      }
    }
    boards.push_back(board);
  }

  int last_win_value = 0;
  for (auto value : calls) {
    for (auto& board : boards) {
      if (board.win_value != 0) continue;

      for (int row = 0; row < 5; row++) {
        for (int col = 0; col < 5; col++) {
          if (board.values[row][col] == value) {
            board.values[row][col] = 0;
            if (board.has_won()) {
              board.win_value = last_win_value = value;
            }
          }
        }
      }
    }
  }

  for (auto& board : boards) {
    if (board.win_value == last_win_value) {
      std::cout << (board.unmarked_sum() * last_win_value) << std::endl;
      return 0;
    }
  }
}
