import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/helpers/screen_size.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_rounded_elevated_button.dart';
import 'package:flutter/material.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScreenSize.initContext(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomRoundedElevatedButton(
                roundedRadius: 3,
                backgroundColor: ThemeEnum.whiteD5Color,
                child: const RegularText(StringsManager.searching),
                onPressed: () {
                  context.pushTo(Routes.searching);
                },
              ),
              CustomRoundedElevatedButton(
                roundedRadius: 3,
                backgroundColor: ThemeEnum.whiteD5Color,
                child: const RegularText(StringsManager.sorting),
                onPressed: () {
                  context.pushTo(Routes.sorting);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
