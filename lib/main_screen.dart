import 'package:flutter/material.dart';
import 'package:flutter_sudoku_apps/pickDialog.dart';
import 'package:flutter_sudoku_apps/sudoku.dart';

class SudokuGame extends StatefulWidget {
  const SudokuGame({super.key});
  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  late final SudokuBoard board = SudokuBoard();

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    board.generateFullSolution();
    board.createPuzzle(cellsToRemove: 45);
    setState(() {});
  }

  /// Обработчик тапа по ячейке — открывает диалог выбора числа
  Future<void> _onCellTapped(int r, int c) async {
    // Блокируем редактирование исходных ячеек
    if (board.puzzle[r][c] != 0 && _isOriginalCell(r, c)) return;

    final current = board.puzzle[r][c] == 0 ? null : board.puzzle[r][c];

    final result = await showDialog<int>(
      context: context,
      builder: (_) => NumberPickerDialog(
        currentValue: current,
        isOriginal: _isOriginalCell(r, c),
      ),
    );

    // Если пользователь нажал "Отмена" или закрыл диалог
    if (result == null) return;

    // 0 означает удаление значения
    if (result == 0) {
      board.puzzle[r][c] = 0;
      setState(() {});
      return;
    }

    // Валидация хода по правилам судоку
    final isValid = board.isValidMove(r, c, result);

    // Опционально: проверка на совпадение с решением (для режима "проверки")
    // final isCorrect = board.matchesSolution(r, c, result);

    board.puzzle[r][c] = result;

    // Визуальная обратная связь
    _showValidationFeedback(r, c, isValid, result);

    // Проверка на завершение игры
    if (board.isPuzzleComplete() && mounted) {
      _showWinDialog();
    }

    setState(() {});
  }

  /// Проверка: является ли ячейка исходной (не редактируемой)
  bool _isOriginalCell(int r, int c) {
    return board.puzzle[r][c] != 0 &&
        board.solution[r][c] == board.puzzle[r][c];
  }

  /// Показ диалога победы
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 Поздравляем!'),
        content: const Text('Вы успешно решили судоку!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // закрыть диалог
              Navigator.pop(context); // закрыть игру или вернуться
            },
            child: const Text('Новая игра'),
          ),
        ],
      ),
    );
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
      appBar: AppBar(
        title: const Text('Судоку'),
        shadowColor: Colors.black,
        elevation: 11,
        actions: [
          TextButton.icon(
            onPressed: _newGame,
            icon: const Icon(Icons.check),
            label: const Text('Начать новую игру'),
          ),
        ],
      ),
      body: Center(
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
    );
  }

  Widget _buildCell(int r, int c) {
    final value = board.puzzle[r][c];
    final isOriginal = _isOriginalCell(r, c);
    final isEmpty = value == 0;

    return GestureDetector(
      onTap: () => _onCellTapped(r, c),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          // border: Border.all(
          //   color: (r % 3 == 0 && r != 0) || (c % 3 == 0 && c != 0)
          //       ? Colors.black
          //       : Colors.grey.shade300,
          //   width: (r % 3 == 0 && r != 0) || (c % 3 == 0 && c != 0) ? 2.5 : 1,
          // ),
          color: isOriginal
              ? Colors.grey.shade200
              : (isEmpty ? Colors.white : Colors.blue.shade50),
        ),
        child: Center(
          child: Text(
            isEmpty ? '' : '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: isOriginal ? FontWeight.bold : FontWeight.w500,
              color: isOriginal
                  ? Colors.black87
                  : (isEmpty ? null : Colors.blue.shade900),
            ),
          ),
        ),
      ),
    );
  }
}
