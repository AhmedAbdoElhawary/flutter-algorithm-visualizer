import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:algorithm_visualizer/features/settings/widgets/account_dialog_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renames the profile.
///
/// Sits beside change-email and change-password rather than on the profile
/// header, so the one place that edits the account is Settings. Unlike those
/// two it asks for no password: a display name is a label, not a credential,
/// and `ProfileNotifier.updateDisplayName` works for a guest as well as a
/// signed-in user — which is why guests get this row too.
class ChangeDisplayNameDialog extends ConsumerStatefulWidget {
  const ChangeDisplayNameDialog({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<ChangeDisplayNameDialog> createState() => _ChangeDisplayNameDialogState();
}

class _ChangeDisplayNameDialogState extends ConsumerState<ChangeDisplayNameDialog> {
  late final TextEditingController _controller;
  late final String _currentName;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _currentName = ref.read(currentUserNameProvider);
    _controller = TextEditingController(text: _currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Mirrors `ProfileNotifier.validateUpdateDisplayName`, which only reports
  /// pass/fail. Repeating the two rules here is what lets the field show
  /// *which* one failed instead of failing silently.
  String? _validate(String name) {
    if (name.isEmpty) return StringsManager.newDisplayNameRequired;
    if (name.length < 2) return StringsManager.nameMinLength;
    if (name == _currentName) return StringsManager.sameDisplayNameAsCurrent;
    return null;
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    final error = _validate(name);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    final updated = await ref.read(profileProvider.notifier).updateDisplayName(name: name);
    if (!mounted) return;

    if (!updated) {
      setState(() {
        _loading = false;
        _error = StringsManager.notValidName;
      });
      return;
    }

    widget.onClose();
    context.showSnackBar(
      message: StringsManager.displayNameUpdated,
      type: CustomSnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AccountDialogShell(
      icon: Icons.badge_outlined,
      title: StringsManager.changeDisplayNameTitle,
      description: StringsManager.changeDisplayNameDialogDesc,
      confirmLabel: StringsManager.saveChanges,
      loading: _loading,
      onCancel: widget.onClose,
      onConfirm: _submit,
      fields: [
        AuthTextField(
          label: StringsManager.newDisplayName,
          hintText: StringsManager.newDisplayNameHint,
          prefixIcon: Icons.person_outline_rounded,
          controller: _controller,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.done,
          errorText: _error,
          // Clears the message as soon as the user starts fixing it, rather
          // than leaving a stale error under a field they have already
          // corrected.
          onChanged: (_) => _error == null ? null : setState(() => _error = null),
          onSubmitted: (_) => _loading ? null : _submit(),
        ),
      ],
    );
  }
}
