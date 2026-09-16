import 'package:flutter/widgets.dart';

/// Pins a subtree to left-to-right, whatever the app language is.
///
/// Most of the app should mirror in Arabic — that is the point of RTL. Two
/// kinds of thing must not:
///
/// * **Code.** Source is read left to right in every language on earth.
///   Mirroring it would move the gutter to the right of the line numbers,
///   run the caret backwards and reverse brackets on screen.
/// * **Indexed data the code refers to.** A sorting bar chart or a
///   pathfinding grid is not prose — `arr[0]` is the *first* bar, and the
///   status line, the pseudocode and the learner's own mental model all
///   agree that first means leftmost. Mirroring the canvas would silently
///   disagree with all three.
///
/// Everything else — labels, captions, buttons around these — stays outside
/// and mirrors normally.
class LtrContent extends StatelessWidget {
  const LtrContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.ltr, child: child);
  }
}
