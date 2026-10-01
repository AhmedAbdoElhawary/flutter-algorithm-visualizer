import 'package:algorithm_visualizer/bootstrap.dart';
import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'journeys/account_journey.dart';
import 'journeys/first_launch_journey.dart';
import 'journeys/searching_journey.dart';
import 'journeys/settings_journey.dart';
import 'journeys/solve_problem_journey.dart';
import 'journeys/sorting_journey.dart';
import 'journeys/wrong_answer_journey.dart';
import 'support/reset.dart';

/// Run through `tool/integration_test.sh`, which starts the Firebase emulators this talks to.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => prepareApp(FlavorConfig.fromEnvironment()));
  setUp(resetAll);

  firstLaunchJourney();
  sortingJourney();
  searchingJourney();
  solveProblemJourney();
  wrongAnswerJourney();
  accountJourney();
  settingsJourney();
}
