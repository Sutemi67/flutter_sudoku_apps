class SudokuValidator {
  bool isValidMove(List<List<int>> board, int row, int col, int value) {
    if (value < 1 || value > 9) return false;

    for (int c = 0; c < 9; c++) {
      if (c != col && board[row][c] == value) return false;
    }
    for (int r = 0; r < 9; r++) {
      if (r != row && board[r][col] == value) return false;
    }
    final startR = row - row % 3;
    final startC = col - col % 3;
    for (int r = startR; r < startR + 3; r++) {
      for (int c = startC; c < startC + 3; c++) {
        if ((r != row || c != col) && board[r][c] == value) return false;
      }
    }
    return true;
  }

  bool matchesSolution(List<List<int>> solution, int row, int col, int value) {
    return solution[row][col] == value;
  }

  bool isPuzzleComplete(List<List<int>> board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0 || !isValidMove(board, r, c, board[r][c])) {
          return false;
        }
      }
    }
    return true;
  }
}
