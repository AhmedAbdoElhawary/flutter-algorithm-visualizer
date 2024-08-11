import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomAppBarBackButton extends StatelessWidget {
  const CustomAppBarBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const CustomBackButtonIcon(),

      onPressed: () {
        Navigator.maybePop(context);
      },
    );
  }
}

class CustomBackButtonIcon extends ConsumerWidget {
  const CustomBackButtonIcon({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return const BackButtonIcon();
  }
}
