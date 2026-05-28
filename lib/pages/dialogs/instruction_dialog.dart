import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foood/models/instruction.dart';
import '../../../providers/providers.dart';

class InstructionDialog extends ConsumerStatefulWidget {
  final Instruction? instruction;

  const InstructionDialog({super.key, this.instruction});

  @override
  ConsumerState<InstructionDialog> createState() => _InstructionDialogState();
}

class _InstructionDialogState extends ConsumerState<InstructionDialog> {
  late final TextEditingController _controller;

  bool get _isEditing => widget.instruction != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.instruction?.text ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
    final recipeId = ref.read(activeRecipeIdProvider);
    final notifier = ref.read(recipesProvider.notifier);

    if (_isEditing) {
      await notifier.updateInstruction(
        instructionId: widget.instruction!.id,
        text: _controller.text,
      );
    } else {
      await notifier.addInstruction(recipeId, _controller.text);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Instruction' : 'Add Instruction'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Instruction',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
