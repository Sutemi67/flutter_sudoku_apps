import 'dart:math';

class SudokuBoard {
  List<List<int>> puzzle = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> solution = List.generate(9, (_) => List.filled(9, 0));
  final Random _random = Random();
}

extension SudokuGenerator on SudokuBoard {
  bool generateFullSolution() {
    return _solve(solution);
  }

  bool _solve(List<List<int>> board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          List<int> candidates = List.generate(9, (i) => i + 1)
            ..shuffle(_random);

          for (int num in candidates) {
            if (_isValidPlacement(board, r, c, num)) {
              board[r][c] = num;
              if (_solve(board)) return true;
              board[r][c] = 0; // backtracking
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValidPlacement(List<List<int>> board, int row, int col, int num) {
    // Проверка строки
    for (int c = 0; c < 9; c++) {
      if (board[row][c] == num) return false;
    }

    // Проверка столбца
    for (int r = 0; r < 9; r++) {
      if (board[r][col] == num) return false;
    }
    // Проверка квадрата 3x3
    int startR = row - row % 3, startC = col - col % 3;
    for (int r = startR; r < startR + 3; r++) {
      for (int c = startC; c < startC + 3; c++) {
        if (board[r][c] == num) {
          return false;
        }
      }
    }
    return true;
  }

  void createPuzzle({int cellsToRemove = 40}) {
    // 1. Сначала генерируем полное решение
    puzzle = solution.map((row) => List<int>.from(row)).toList();

    int removed = 0;
    List<List<bool>> visited = List.generate(9, (_) => List.filled(9, false));

    while (removed < cellsToRemove) {
      int r = _random.nextInt(9);
      int c = _random.nextInt(9);

      if (visited[r][c]) continue;
      visited[r][c] = true;

      // Удаляем ячейку
      puzzle[r][c] = 0;

      // ⚠️ Для production: здесь нужно проверить, что решений остаётся ровно 1
      // if (!_hasUniqueSolution(puzzle)) { puzzle[r][c] = backup; continue; }

      removed++;
    }
  }
}

extension SudokuValidator on SudokuBoard {
  /// Проверка корректности хода по правилам судоку
  bool isValidMove(int row, int col, int value) {
    if (value < 1 || value > 9) return false;

    // Строка
    for (int c = 0; c < 9; c++) {
      if (c != col && puzzle[row][c] == value) return false;
    }
    // Столбец
    for (int r = 0; r < 9; r++) {
      if (r != row && puzzle[r][col] == value) return false;
    }
    // Квадрат 3x3
    int startR = row - row % 3, startC = col - col % 3;
    for (int r = startR; r < startR + 3; r++) {
      for (int c = startC; c < startC + 3; c++) {
        if ((r != row || c != col) && puzzle[r][c] == value) return false;
      }
    }
    return true;
  }

  /// Проверка совпадения с заранее сгенерированным решением
  bool matchesSolution(int row, int col, int value) {
    return solution[row][col] == value;
  }

  /// Проверка полного заполнения и корректности
  bool isPuzzleComplete() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (puzzle[r][c] == 0 || !isValidMove(r, c, puzzle[r][c])) return false;
      }
    }
    return true;
  }
}
