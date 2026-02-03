import 'package:flutter/material.dart';

class GroundingCard extends StatelessWidget {
  final String instruction;
  final VoidCallback onNext;
  final String nextLabel;

  const GroundingCard({
    super.key,
    required this.instruction,
    required this.onNext,
    this.nextLabel = 'Next',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          instruction,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(height: 1.4),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onNext,
            child: Text(nextLabel),
          ),
        ),
      ],
    );
  }
}
