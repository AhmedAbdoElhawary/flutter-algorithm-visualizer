import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'grid_notifier_state.dart';

class GridNotifierCubit extends StateNotifier<GridNotifierInitial> {
  GridNotifierCubit() : super(GridNotifierInitial());

}
