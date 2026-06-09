import 'dart:math';
import 'board.dart';

class SudokuGenerator {
  final Random _random = Random();

  SudokuBoard generate({int cellsToRemove = 40}) {
    final solution = _generateFullSolution();
    final puzzle = _createPuzzle(solution, cellsToRemove);
    return SudokuBoard(
      puzzle: puzzle,
      solution: solution,
      originalCells: _findOriginalCells(puzzle),
    );
  }

  List<List<int>> _generateFullSolution() {
    final board = List.generate(9, (_) => List.filled(9, 0));
    final success = _solve(board);
    if (!success) {
      throw StateError('Failed to generate Sudoku solution');
    }
    return board;
  }

  bool _solve(List<List<int>> board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          final candidates = List<int>.generate(9, (i) => i + 1)
            ..shuffle(_random);

          for (final num in candidates) {
            if (_isValidPlacement(board, r, c, num)) {
              board[r][c] = num;
              if (_solve(board)) return true;
              board[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValidPlacement(List<List<int>> board, int row, int col, int num) {
    for (int c = 0; c < 9; c++) {
      if (board[row][c] == num) return false;
    }
    for (int r = 0; r < 9; r++) {
      if (board[r][col] == num) return false;
    }
    final startR = row - row % 3;
    final startC = col - col % 3;
    for (int r = startR; r < startR + 3; r++) {
      for (int c = startC; c < startC + 3; c++) {
        if (board[r][c] == num) return false;
      }
    }
    return true;
  }

  List<List<int>> _createPuzzle(List<List<int>> solution, int cellsToRemove) {
    final puzzle = solution.map((row) => List<int>.from(row)).toList();
    final indices = List<int>.generate(81, (i) => i)..shuffle(_random);

    final count = cellsToRemove.clamp(0, 81);
    for (int i = 0; i < count; i++) {
      final r = indices[i] ~/ 9;
      final c = indices[i] % 9;
      puzzle[r][c] = 0;
    }
    return puzzle;
  }

  Set<int> _findOriginalCells(List<List<int>> puzzle) {
    final cells = <int>{};
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (puzzle[r][c] != 0) {
          cells.add(r * 9 + c);
        }
      }
    }
    return cells;
  }
}
