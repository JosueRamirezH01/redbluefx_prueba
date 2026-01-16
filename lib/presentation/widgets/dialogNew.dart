import 'package:flutter/material.dart';


Future<void> showMessageDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Aceptar',
  String? cancelText,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool barrierDismissible = false,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onCancel?.call();
              },
              child: Text(
                cancelText,
                style: TextStyle(
                  color: colorScheme.error,
                ),
              ),
            ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
}
