part of 'route_app.dart';


class _UnknownPage extends StatelessWidget {
  const _UnknownPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(),
      body: const Center(child: RegularText(StringsManager.unknownPage)),
    );
  }
}
