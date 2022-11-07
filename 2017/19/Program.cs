using System.Text;

var data = File.ReadLines("input.txt").ToArray();
var rows = data.Length;
var cols = data[0].Length;
(int row, int col) pos = (0, 0);
(int row, int col) dir = (1, 0);
for (var col = 0; col < data[0].Length; ++col) {
  if (data[0][col] == '|') {
    pos = (0, col);
    break;
  }
}

char GetData ((int row, int col) pos) {
  return (pos.row < 0 || pos.row >= data.Length || pos.col < 0 || pos.col >= data[pos.row].Length)
    ? ' ' : data[pos.row][pos.col];
}

var letters = new StringBuilder();
var count = 0;
while (true) {
  pos.row += dir.row;
  pos.col += dir.col;
  ++count;
  var ch = GetData(pos);
  if (Char.IsLetter(ch)) letters.Append(ch);
  else if (ch == ' ') break;
  else if (ch == '+') {
    if (dir != (1, 0) && GetData((pos.row - 1, pos.col)) != ' ') dir = (-1, 0);
    else if (dir != (-1, 0) && GetData((pos.row + 1, pos.col)) != ' ') dir = (1, 0);
    else if (dir != (0, 1) && GetData((pos.row, pos.col - 1)) != ' ') dir = (0, -1);
    else if (dir != (0, -1) && GetData((pos.row, pos.col + 1)) != ' ') dir = (0, 1);
  }
}

Console.WriteLine(letters);
Console.WriteLine(count);
