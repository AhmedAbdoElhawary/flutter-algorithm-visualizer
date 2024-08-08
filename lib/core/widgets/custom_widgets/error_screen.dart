import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen(this.detailsException, {super.key});
  final dynamic detailsException;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: AllPadding(
        padding: 20,
        child: foundation.kReleaseMode
            ? const Center(
                child: RegularText(StringsManager.sorryForInconvenience,
                    fontSize: 18),
              )
            : Center(
                child: RegularText('Exception Details: $detailsException',
                    maxLines: 5),
              ),
      ),
    );
  }
}
