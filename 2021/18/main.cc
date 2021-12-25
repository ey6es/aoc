#include <algorithm>
#include <cctype>
#include <fstream>
#include <iostream>
#include <memory>
#include <string>
#include <vector>

struct Number;

struct explode_result {
  std::shared_ptr<Number> number;
  int left_add;
  int right_add;
};

struct Number {

  virtual ~Number () {}

  virtual void print (std::ostream& out) const = 0;

  virtual int magnitude () const = 0;

  virtual explode_result maybe_explode (int depth) const = 0;

  virtual std::shared_ptr<Number> maybe_split () const = 0;

  virtual int require_scalar () const = 0;

  virtual std::shared_ptr<Number> maybe_left_add (int increment) const = 0;

  virtual std::shared_ptr<Number> maybe_right_add (int increment) const = 0;
};

struct Scalar : public Number {
  int value;

  Scalar (int value) : value(value) {}

  virtual void print (std::ostream& out) const {
    out << value;
  }

  virtual int magnitude () const {
    return value;
  }

  virtual explode_result maybe_explode (int depth) const {
    return {};
  }

  virtual std::shared_ptr<Number> maybe_split () const;

  virtual int require_scalar () const {
    return value;
  }

  virtual std::shared_ptr<Number> maybe_left_add (int increment) const {
    return std::shared_ptr<Number>(new Scalar(value + increment));
  }

  virtual std::shared_ptr<Number> maybe_right_add (int increment) const {
    return std::shared_ptr<Number>(new Scalar(value + increment));
  }
};

class exception : public std::exception {
public:

  exception (const std::string& what) : what_(what) {}

  virtual const char* what () const noexcept {
    return what_.c_str();
  }

private:

  std::string what_;
};

struct Pair : public Number {
  std::shared_ptr<Number> left;
  std::shared_ptr<Number> right;

  Pair (
    const std::shared_ptr<Number>& left,
    const std::shared_ptr<Number>& right
  ) : left(left), right(right) {}

  virtual void print (std::ostream& out) const {
    out << '[';
    left->print(out);
    out << ',';
    right->print(out);
    out << ']';
  }

  virtual int magnitude () const {
    return 3 * left->magnitude() + 2 * right->magnitude();
  }

  virtual explode_result maybe_explode (int depth) const {
    auto exploded_left = left->maybe_explode(depth + 1);
    if (exploded_left.number) {
      explode_result result {};
      result.left_add = exploded_left.left_add;

      auto added_right = right->maybe_left_add(exploded_left.right_add);
      if (added_right) {
        result.number = std::shared_ptr<Number>(new Pair(exploded_left.number, added_right));
      } else {
        result.number = std::shared_ptr<Number>(new Pair(exploded_left.number, right));
        result.right_add = exploded_left.right_add;
      }

      return result;
    }
    auto exploded_right = right->maybe_explode(depth + 1);
    if (exploded_right.number) {
      explode_result result {};
      result.right_add = exploded_right.right_add;

      auto added_left = left->maybe_right_add(exploded_right.left_add);
      if (added_left) {
        result.number = std::shared_ptr<Number>(new Pair(added_left, exploded_right.number));
      } else {
        result.number = std::shared_ptr<Number>(new Pair(left, exploded_right.number));
        result.left_add = exploded_right.left_add;
      }

      return result;
    }
    if (depth < 4) return {};
    return {
      std::shared_ptr<Number>(new Scalar(0)),
      left->require_scalar(), right->require_scalar() };
  }

  virtual std::shared_ptr<Number> maybe_split () const {
    auto split_left = left->maybe_split();
    if (split_left) return std::shared_ptr<Number>(new Pair(split_left, right));
    auto split_right = right->maybe_split();
    if (split_right) return std::shared_ptr<Number>(new Pair(left, split_right));
    return std::shared_ptr<Number>();
  }

  virtual int require_scalar () const {
    throw exception("Expected scalar");
  }

  virtual std::shared_ptr<Number> maybe_left_add (int increment) const {
    auto added_left = left->maybe_left_add(increment);
    if (added_left) {
      return std::shared_ptr<Number>(new Pair(added_left, right));
    }
    auto added_right = right->maybe_left_add(increment);
    if (added_right) {
      return std::shared_ptr<Number>(new Pair(left, added_right));
    }
    return std::shared_ptr<Number>();
  }

  virtual std::shared_ptr<Number> maybe_right_add (int increment) const {
    auto added_right = right->maybe_right_add(increment);
    if (added_right) {
      return std::shared_ptr<Number>(new Pair(left, added_right));
    }
    auto added_left = left->maybe_right_add(increment);
    if (added_left) {
      return std::shared_ptr<Number>(new Pair(added_left, right));
    }
    return std::shared_ptr<Number>();
  }
};

std::shared_ptr<Number> Scalar::maybe_split () const {
  if (value < 10) return std::shared_ptr<Number>();
  int half = value / 2;
  return std::shared_ptr<Number>(new Pair(
    std::shared_ptr<Number>(new Scalar(half)),
    std::shared_ptr<Number>(new Scalar(value - half))
  ));
}

std::shared_ptr<Number> parse_number (std::string::iterator& it) {
  if (*it == '[') {
    auto left = parse_number(++it);
    if (*it++ != ',') throw exception("Unexpected char");
    auto right = parse_number(it);
    if (*it++ != ']') throw exception("Unexpected char");
    return std::shared_ptr<Number>(new Pair(left, right));

  } else {
    auto start = it;
    while (std::isdigit(*it)) it++;
    return std::shared_ptr<Number>(new Scalar(std::stoi(std::string(start, it))));
  }
}

std::shared_ptr<Number> add (
  const std::shared_ptr<Number>& first,
  const std::shared_ptr<Number>& second
) {
  auto result = std::shared_ptr<Number>(new Pair(first, second));
  while (true) {
    auto exploded = result->maybe_explode(0);
    if (exploded.number) {
      result = exploded.number;
    } else {
      auto split = result->maybe_split();
      if (split) result = split;
      else break;
    }
  }
  return result;
}

int main () {
  std::ifstream in("input.txt");

  std::vector<std::shared_ptr<Number>> numbers;

  while (in.good()) {
    std::string line;
    std::getline(in, line);

    if (!line.empty()) {
      auto it = line.begin();
      numbers.push_back(parse_number(it));
    }
  }

  int largest_magnitude = 0;
  for (int i = 0; i < numbers.size(); i++) {
    for (int j = 0; j < numbers.size(); j++) {
      if (i == j) continue;
      auto sum = add(numbers[i], numbers[j]);
      largest_magnitude = std::max(largest_magnitude, sum->magnitude());
    }
  }

  std::cout << largest_magnitude << std::endl;
}
