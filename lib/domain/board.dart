class SudokuBoard {
  final List<List<int>> puzzle;
  final List<List<int>> solution;
  final Set<int> originalCells;

  SudokuBoard({
    required this.puzzle,
    required this.solution,
    required this.originalCells,
  });

  int getCell(int row, int col) => puzzle[row][col];
  bool isOriginalCell(int row, int col) => originalCells.contains(row * 9 + col);
}
