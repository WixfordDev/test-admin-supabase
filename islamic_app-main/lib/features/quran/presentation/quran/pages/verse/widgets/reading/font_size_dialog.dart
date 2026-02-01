import 'package:flutter/material.dart';

class FontSizeDialog extends StatefulWidget {
  final double initialSize;
  final ValueChanged<double> onSizeChanged;

  const FontSizeDialog({
    super.key,
    required this.initialSize,
    required this.onSizeChanged,
  });

  @override
  State<FontSizeDialog> createState() => FontSizeDialogState();
}

class FontSizeDialogState extends State<FontSizeDialog> {
  late double _currentSize;

  @override
  void initState() {
    super.initState();
    _currentSize = widget.initialSize;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Adjust Text Size',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: _currentSize,
                height: 2.0,
                color: const Color(0xFF2E7D32),
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Small',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Large',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Slider(
            value: _currentSize,
            min: 20,
            max: 36,
            divisions: 8,
            activeColor: const Color(0xFF2E7D32),
            inactiveColor: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            label: _currentSize.round().toString(),
            onChanged: (value) {
              setState(() {
                _currentSize = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSizeChanged(_currentSize);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
