import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sudoku_apps/sudoku.dart';

class SudokuGame extends StatefulWidget {
  const SudokuGame({super.key});
  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  late final SudokuBoard board = SudokuBoard();
  final List<List<TextEditingController>> controllers = List.generate(
    9,
    (_) => List.generate(9, (_) => TextEditingController()),
  );

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    board.generateFullSolution();
    board.createPuzzle(cellsToRemove: 45);

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        controllers[r][c].text = board.puzzle[r][c] == 0
            ? ''
            : '${board.puzzle[r][c]}';
      }
    }
    setState(() {});
  }

  void _onCellChanged(int r, int c, String value) {
    if (value.isEmpty) {
      board.puzzle[r][c] = 0;
      return;
    }

    int num = int.tryParse(value) ?? 0;
    if (num < 1 || num > 9) return;

    // Блокируем редактирование исходных ячеек
    // (в реальном приложении храните Set<Offset> initialCells)

    bool valid = board.isValidMove(r, c, num);
    board.puzzle[r][c] = num;

    // Визуальная обратная связь
    _showValidationFeedback(r, c, valid, num);
  }

  void _showValidationFeedback(int r, int c, bool valid, int value) {
    // Пример: подсветка ошибки через SnackBar или изменение цвета ячейки
    if (!valid && !mounted) return;
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Число $value конфликтует с правилами'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Судоку')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                int r = index ~/ 9, c = index % 9;
                return _buildCell(r, c);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _newGame,
              child: const Text('Новая игра'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int r, int c) {
    final isOriginal =
        board.puzzle[r][c] != 0 && controllers[r][c].text.isNotEmpty;
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: isOriginal ? Colors.grey.shade100 : Colors.white,
      ),
      child: TextField(
        controller: controllers[r][c],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        enabled: !isOriginal, // Исходные ячейки не редактируются
        style: TextStyle(
          fontWeight: isOriginal ? FontWeight.bold : FontWeight.normal,
          color: isOriginal ? Colors.black87 : Colors.blue,
        ),
        onChanged: (val) => _onCellChanged(r, c, val),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
