import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class VerificationStepIndicator extends StatelessWidget {
  final int currentStep; // 1, 2, or 3

  const VerificationStepIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    const steps = [
      (1, 'Identity'),
      (2, 'Review'),
      (3, 'Approved'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _buildStepCircle(
              stepNumber: steps[i].$1,
              title: steps[i].$2,
              isActive: currentStep == steps[i].$1,
              isCompleted: currentStep > steps[i].$1,
            ),
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: currentStep > steps[i].$1
                      ? AppTheme.primary
                      : AppTheme.outlineLighter,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepCircle({
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    final color = isCompleted || isActive ? AppTheme.primary : AppTheme.textTertiary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppTheme.primary
                : isActive
                    ? AppTheme.primary
                    : Colors.transparent,
            border: Border.all(
              color: color,
              width: isActive ? 2 : 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.w500,
            color: isActive || isCompleted ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
