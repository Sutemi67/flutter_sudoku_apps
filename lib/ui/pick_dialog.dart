import 'package:flutter/material.dart';

class NumberPickerDialog extends StatelessWidget {
  final int? currentValue;
  final bool isOriginal; // Блокируем изменение исходных ячеек

  const NumberPickerDialog({
    super.key,
    this.currentValue,
    this.isOriginal = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выберите число'),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 10, // 1-9 + крестик
          itemBuilder: (context, index) {
            if (index == 9) {
              // Кнопка удаления
              return _NumberButton(
                label: '✕',
                color: Colors.red.shade100,
                textColor: Colors.red,
                isSelected: false,
                onTap: isOriginal ? null : () => Navigator.pop(context, 0),
              );
            }
            final num = index + 1;
            return _NumberButton(
              label: '$num',
              isSelected: currentValue == num,
              onTap: isOriginal ? null : () => Navigator.pop(context, num),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Отмена'),
        ),
      ],
    );
  }
}

class _NumberButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final Color? textColor;
  final VoidCallback? onTap;

  const _NumberButton({
    required this.label,
    required this.isSelected,
    this.color,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Theme.of(context).primaryColor.withAlpha(44)
          : color ?? Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color:
                  textColor ??
                  (isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}
