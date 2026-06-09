import 'package:flutter/material.dart';
import 'package:flutter_sudoku_apps/domain/board.dart';
import 'package:flutter_sudoku_apps/domain/generator.dart';
import 'package:flutter_sudoku_apps/domain/validator.dart';
import 'package:flutter_sudoku_apps/ui/pick_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final SudokuGenerator _generator = SudokuGenerator();
  final SudokuValidator _validator = SudokuValidator();
  late SudokuBoard _board;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _board = _generator.generate(cellsToRemove: 45);
    setState(() {});
  }

  Future<void> _onCellTapped(int r, int c) async {
    if (_board.isOriginalCell(r, c)) return;

    final current = _board.getCell(r, c) == 0 ? null : _board.getCell(r, c);

    final result = await showDialog<int>(
      context: context,
      builder: (_) => NumberPickerDialog(currentValue: current),
    );

    if (result == null) return;

    if (result == 0) {
      _board.puzzle[r][c] = 0;
      setState(() {});
      return;
    }

    final isValid = _validator.isValidMove(_board.puzzle, r, c, result);
    _board.puzzle[r][c] = result;

    if (!isValid && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Число $result конфликтует с правилами'), duration: const Duration(seconds: 1)),
      );
    }

    if (_validator.isPuzzleComplete(_board.puzzle) && mounted) {
      _showWinDialog();
    }

    setState(() {});
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Поздравляем!'),
        content: const Text('Вы успешно решили судоку!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _newGame();
            },
            child: const Text('Новая игра'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Судоку'),
        shadowColor: Colors.black,
        elevation: 11,
        actions: [
          TextButton.icon(onPressed: _newGame, icon: const Icon(Icons.refresh), label: const Text('Новая игра')),
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
            itemCount: 81,
            itemBuilder: (context, index) {
              int r = index ~/ 9, c = index % 9;
              return _buildCell(r, c);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int r, int c) {
    final value = _board.getCell(r, c);
    final isOriginal = _board.isOriginalCell(r, c);
    final isEmpty = value == 0;

    return GestureDetector(
      onTap: () => _onCellTapped(r, c),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isOriginal ? Colors.grey.shade200 : (isEmpty ? Colors.white : Colors.blue.shade50),
          border: Border(
            top: BorderSide(color: Colors.black45, width: r % 3 == 0 ? 1.5 : 0.3),
            bottom: BorderSide(color: Colors.black45, width: r % 3 == 2 ? 1.5 : 0.3),
            left: BorderSide(color: Colors.black45, width: c % 3 == 0 ? 1.5 : 0.3),
            right: BorderSide(color: Colors.black45, width: c % 3 == 2 ? 1.5 : 0.3),
          ),
        ),
        child: Center(
          child: Text(
            isEmpty ? '' : '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: isOriginal ? FontWeight.bold : FontWeight.w500,
              color: isOriginal ? Colors.black87 : (isEmpty ? null : Colors.blue.shade900),
            ),
          ),
        ),
      ),
    );
  }
}
