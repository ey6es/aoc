#include <fstream>
#include <iostream>
#include <memory>
#include <stack>
#include <string>
#include <vector>

struct Instruction {
  int a;

  Instruction (int a) : a(a) {}

  virtual ~Instruction () {}

  virtual void execute (long long variables[4], std::stack<int>& input) const = 0;
};

struct Inp : public Instruction {

  Inp (int a) : Instruction(a) {}

  virtual void execute (long long variables[4], std::stack<int>& input) const {
    variables[a] = input.top();
    input.pop();
  }
};

struct Value {

  virtual ~Value() {}

  virtual long long get (long long variables[4]) const = 0;
};

struct Variable : public Value {
  int index;

  Variable (int index) : index(index) {}

  virtual long long get (long long variables[4]) const {
    return variables[index];
  }
};

struct Literal : public Value {
  int value;

  Literal (int value) : value(value) {}

  virtual long long get (long long variables[4]) const {
    return value;
  }
};

struct BinaryInstruction : public Instruction {
  std::shared_ptr<Value> b;

  BinaryInstruction (int a, const std::shared_ptr<Value>& b)
    : Instruction(a), b(b) {}
};

struct Add : public BinaryInstruction {

  Add (int a, const std::shared_ptr<Value>& b) : BinaryInstruction(a, b) {}

  virtual void execute (long long variables[4], std::stack<int>& input) const {
    variables[a] += b->get(variables);
  }
};

struct Mul : public BinaryInstruction {

  Mul (int a, const std::shared_ptr<Value>& b) : BinaryInstruction(a, b) {}

  virtual void execute (long long variables[4], std::stack<int>& input) const {
    variables[a] *= b->get(variables);
  }
};

struct Div : public BinaryInstruction {

  Div (int a, const std::shared_ptr<Value>& b) : BinaryInstruction(a, b) {}

  virtual void execute (long long variables[4], std::stack<int>& input) const {
    variables[a] /= b->get(variables);
  }
};

struct Mod : public BinaryInstruction {

  Mod (int a, const std::shared_ptr<Value>& b) : BinaryInstruction(a, b) {}

  virtual void execute (long long variables[4], std::stack<int>& input) const {
    variables[a] %= b->get(variables);
  }
};

struct Eql : public BinaryInstruction {

  Eql (int a, const std::shared_ptr<Value>& b) : BinaryInstruction(a, b) {}

  virtual void execute (long long variables[4], std::stack<int>& input) const {
    variables[a] = (variables[a] == b->get(variables));
  }
};

int main () {
  std::ifstream in("input.txt");

  std::vector<std::shared_ptr<Instruction>> instructions;

  while (in.good()) {
    std::string line;
    std::getline(in, line);
    if (line.empty()) continue;

    auto idx = line.find(' ');
    auto instruction = line.substr(0, idx);
    auto a = line[idx + 1] - 'w';

    if (instruction == "inp") {
      instructions.push_back(std::shared_ptr<Instruction>(new Inp(a)));

    } else {
      idx = line.rfind(' ');
      auto b_value = line.substr(idx + 1);
      std::shared_ptr<Value> b;

      if (b_value[0] >= 'w' && b_value[0] <= 'z') {
        b = std::shared_ptr<Value>(new Variable(b_value[0] - 'w'));
      } else {
        b = std::shared_ptr<Value>(new Literal(std::stoi(b_value)));
      }

      if (instruction == "add") {
        instructions.push_back(std::shared_ptr<Instruction>(new Add(a, b)));
      } else if (instruction == "mul") {
        instructions.push_back(std::shared_ptr<Instruction>(new Mul(a, b)));
      } else if (instruction == "div") {
        instructions.push_back(std::shared_ptr<Instruction>(new Div(a, b)));
      } else if (instruction == "mod") {
        instructions.push_back(std::shared_ptr<Instruction>(new Mod(a, b)));
      } else if (instruction == "eql") {
        instructions.push_back(std::shared_ptr<Instruction>(new Eql(a, b)));
      }
    }
  }

  long long variables[4] {};
  std::stack<int> input;

  for (auto value = 16811412161117LL; value; value /= 10) {
    input.push(value % 10);
  }

  for (auto& instruction : instructions) {
    instruction->execute(variables, input);
  }

  std::cout << variables[3] << std::endl;
}
