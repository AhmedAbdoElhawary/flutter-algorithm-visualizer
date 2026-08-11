part of 'route_app.dart';

class _UnknownPage extends StatelessWidget {
  const _UnknownPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(),
      body: UnknownView(),
    );
  }
}

class UnknownView extends StatelessWidget {
  const UnknownView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: RegularText(StringsManager.unknownPage));
  }
}
