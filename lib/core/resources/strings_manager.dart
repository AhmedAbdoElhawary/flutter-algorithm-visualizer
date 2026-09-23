/// [StringsManager] text in english is the same key for translation map
library;

import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:flutter/widgets.dart';

class StringsManager {
  static const String appName = "Algo Dive";

  static const String sorryForInconvenience = "Sorry for inconvenience";
  static const String cancel = "Cancel";
  static const String unknownPage = "Unknown page";
  static const String aStarSearch = "A* Search";
  static const String bFS = "BFS Search";
  static const String dFS = "DFS Search";
  static const String searching = "Searching";
  static const String sorting = "Sorting";

  static const String bubbleSort = "Bubble sort";
  static const String insertionSort = "Insertion sort";
  static const String selectionSort = "Selection sort";
  static const String mergeSort = "Merge sort";
  static const String heapSort = "Heap sort";
  static const String quickSort = "Quick sort";
  static const String radixSort = "Radix sort";
  static const String shellSort = "Shell sort";
  static const String countingSort = "Counting sort";
  static const String bucketSort = "Bucket sort";

  static const String bubbleSortDescription = "Swaps like bubbles rising until the biggest reaches the top.";
  static const String selectionSortDescription = "Selects the smallest item each round and fixes its place.";
  static const String insertionSortDescription = "Inserts each item into its correct sorted position.";
  static const String mergeSortDescription = "Merges divided sorted parts into one ordered list.";
  static const String quickSortDescription = "Quickly partitions data around a chosen pivot value.";
  static const String heapSortDescription = "Uses a heap tree to repeatedly extract the largest item.";
  static const String shellSortDescription = "Improves insertion sort using distant element gaps.";
  static const String radixSortDescription = "Sorts numbers digit by digit from least to greatest.";
  static const String countingSortDescription = "Counts occurrences instead of comparing values directly.";
  static const String bucketSortDescription = "Distributes items into buckets, then sorts each bucket.";

  static const String breadthFirstSearchDescription = "Finds the shortest path level by level.";
  static const String depthFirstSearchDescription = "Explores one path deeply before backtracking.";
  static const String aStarDescription = "Uses heuristics to quickly find the best path.";
  static const String initialArrayReadyToSort = "Initial array - ready to sort";
  static const String arrayFullySorted = "✓ Array fully sorted!";
  static const String swapPositions = "Swap positions";
  static const String compare = "Compare";
  static const String fromRun = "from";
  static const String intoPosition = "into position";

  /// Role-catalogue labels (FR-017) — one constant per [SortRole], shared
  /// verbatim between the legend and the status text (C2.2, FR-040).
  /// [roleCompare] aliases the existing [compare] constant rather than
  /// duplicating its text (C14).
  static const String roleCompare = compare;
  static const String roleSwap = "Swap";
  static const String roleWrite = "Write";
  static const String roleSorted = "Sorted";
  static const String roleMinimum = "Minimum";
  static const String roleHeldValue = "Held value";
  static const String rolePivot = "Pivot";
  static const String roleRightRun = "Right run";
  static const String roleTarget = "Target";
  static const String roleBoundary = "Boundary";
  static const String roleLeftRun = "Left run";
  static const String base = "Base";

  /// Anchor-context status-line prefixes (FR-041), keyed by role rather than
  /// by algorithm (C13, research Decision 6). [pivotPrefix] aliases
  /// [rolePivot] rather than duplicating its text (C14) — "Pivot" reads the
  /// same whether it names the role or prefixes the line.
  static const String minPrefix = "Min";
  static const String pivotPrefix = rolePivot;
  static const String heldPrefix = "Held";

  /// Per-algorithm pointer hints appended to a shared legend label (FR-007).
  static const String pointerHintI = "(i)";
  static const String pointerHintJ = "(j)";

  static const String reset = "Reset";
  static const String time = "Time: ";
  static const String space = "Space: ";
  static const String best = "Best:";
  static const String stable = "Stable:";
  static const String yes = "Yes";
  static const String no = "No";
  static const String start = "Start";
  static const String end = "End";
  static const String searcher = "Searcher";
  static const String visited = "Visited";
  static const String path = "Path";
  static const String wall = "Wall";

  /// Searching role-catalogue labels — one constant per `SearchRole`, shared
  /// verbatim between the grid legend and the explanation line. Each aliases
  /// the existing generic constant above rather than duplicating its text.
  static const String searchRoleStart = start;
  static const String searchRoleEnd = end;
  static const String searchRoleSearcher = searcher;
  static const String searchRoleVisited = visited;
  static const String searchRolePath = path;
  static const String searchRoleWall = wall;

  /// Selection-rule phrases — what the algorithm does, never its name.
  static const String searchRuleOldestFirst = "Oldest first";
  static const String searchRuleNewestFirst = "Newest first";
  static const String searchRuleCheapestFirst = "Cheapest first";
  static const String searchRuleSeparator = " · ";
  static const String searchWaiting = "waiting";
  static const String searchDepth = "depth";
  static const String searchCost = "cost";
  static const String searchToGo = "to go";

  /// Terminal lines and the pre-run hint.
  static const String searchPathFound = "Path found";
  static const String searchStepsSuffix = "steps";
  static const String searchNotShortest = "(not the shortest)";
  static const String searchNoPath = "No path — every reachable cell explored";
  static const String searchPreRunHint = "Drag cells to draw walls, then press Run";

  /// Playback counter — `{current}` and `{total}` are substituted at render time.
  static const String searchStepCounterTemplate = "Step {current} of {total}";

  /// Wall-editing button tooltips.
  static const String clearWalls = "Clear walls";
  static const String randomWalls = "Random walls";
  static const String solved = "solved";
  static const String easy = "Easy";
  static const String medium = "Medium";
  static const String hard = "Hard";
  static const String searchProblem = "Search problems…";
  static const String noProblemsFound = 'No problems found';
  static const String tryADifferentSearchOrFilter = 'Try a different search or filter';
  static const String notAbleToLoadAnyChallenge = 'Not able to load any challenge...';
  static const String tryInDifferentTime = 'Try in different time';
  static const String practice = 'Practice';
  static const String challenges = 'Challenges';
  static const String nan = "NAN";
  static const String solveWithArrow = "Solve →";
  static const String status = "Status";
  static const String all = "All";

  static const String noChallengeSelected = "No challenge selected";

  static const String dart = "Dart";
  static const String language = "Language";
  static const String dartOnlyProblem = "Dart only for now";
  static const String running = "Running...";

  static const String input = "Input";
  static const String output = "Output";
  static const String example = "Example";
  static const String constraints = "Constraints";
  static const String passed = "Passed";
  static const String failed = "Failed";
  static const String notSolved = "Not Solved";

  /// The middle `ProblemStatus`: tried, not yet solved.
  static const String attempted = "Attempted";

  // Profile
  static const String profile = "Profile";
  static const String dayStreak = "Day\nStreak";
  static const String accuracyRate = "Accuracy\nRate";
  static const String bookmarked = "Bookmarked";
  static const String activityHeatmap = "Activity (12 weeks)";
  static const String thisWeek = "This Week";
  static const String less = "Less";
  static const String more = "More";
  static const String solvedLabel = "solved";
  static const String total = "Total";
  static const String viewAll = "View All";
  static const String days = "days";
  static const String problems = "Problems";
  static const String problem = "Problem";

  static const String hints = "Hints";
  static const String similarQuestions = "Similar Questions";
  static const String noHintsYet = "No hints yet";
  static const String noSimilarQuestionsYet = "No similar questions yet";
  static const String practiceHistory = "Practice History";

  // Bookmarks / History (Aurora screens 07 / 09)
  static const String swipeToRemoveBookmark = "Swipe a row to remove it from bookmarks.";
  static const String bookmarkEndTitle = "That is the whole bookmarks";
  static const String historyEndTitle = "That is the whole history";
  static const String longPressExplain = "Long press on the card to jump to the problem";
  static const String lastLabel = "last";
  static const String dayAgo = "day ago";
  static const String daysAgo = "days ago";

  // Problem screen (Aurora screen 03)
  static const String problemTab = "Problem";
  static const String solveInEditor = "Solve in editor";

  // Celebration (Aurora screen 14)
  static const String solvedMoment = "Solved";
  static const String allNTestsPassedPrefix = "all ";
  static const String allNTestsPassedSuffix = " test cases passed";
  static const String nextProblem = "Next problem";
  static const String seeTheVisualTrace = "See the visual trace";

  static const String solvedTopics = "Solved Topics";
  static const String topics = "Topics";
  static const String date = "Date";
  static const String result = "Result";
  static const String difficultyProgress = "Difficulty Progress";
  static const String home = "Home";
  static const String visual = "Visual";
  static const String code = "Code";
  static const String goodMorning = "Good morning";
  static const String goodAfternoon = "Good afternoon";
  static const String goodEvening = "Good evening";
  static const String recentActivity = "Recent Activity";
  static const String justNow = "Just now";
  static const String mAgo = "m ago";
  static const String hAgo = "h ago";
  static const String dAgo = "d ago";
  static const String yesterday = "Yesterday";

  static const String streak = "Streak";
  static const String accuracy = "Accuracy";
  static const String attempts = "Attempts";
  static const String continueLabel = "Continue Learning";
  static const String anonymous = "Anonymous";
  static const String submissions = "Submissions";
  static const String submission = "Submission";

  // Auth Strings — CoreDive screens 11 / 12 / 13
  static const String welcome = "Welcome";
  static const String signInSubtitle = "Sign in to keep your streak and pick up where you stopped.";
  static const String emailAddress = "Email";
  static const String emailHint = "name@example.com";
  static const String password = "Password";
  static const String passwordHint = "••••••••";
  static const String forgotShort = "Forgot?";
  static const String signIn = "Sign in";
  static const String noAccountYet = "Not have account yet?";
  static const String signUp = "Sign up";
  static const String orDivider = "or";

  static const String createAccount = "Create account";
  static const String signUpSubtitle = "Track every problem you solve and build a streak worth keeping.";
  static const String fullName = "Full name";
  static const String fullNameHint = "Ahmed Elhawary";
  static const String createStrongPasswordHint = "••••••";
  static const String confirmPassword = "Confirm password";
  static const String reEnterPasswordHint = "Re-enter password";
  static const String alreadyHaveAccount = "Already have an account?";

  // Password strength meter (CoreDive screen 13)
  static const String pwStrengthWeak = "Weak";
  static const String pwStrengthFair = "Fair";
  static const String pwStrengthGood = "Good";
  static const String pwStrengthStrong = "Strong";
  static const String pwHintAddLength = "add a few more characters";
  static const String pwHintAddNumber = "add a number to strengthen it";
  static const String pwHintAddCase = "mix upper and lower case";
  static const String pwHintAddSymbol = "add a symbol to strengthen it";
  static const String pwHintStrongEnough = "strong enough to keep";
  static const String pwStrengthEmpty = "Use at least 8 characters.";

  static const String accountRecovery = "ACCOUNT RECOVERY";
  static const String resendEmailLink = "Resend email link";
  static const String checkEmail = "Check your email";
  static const String noteReceiveTheLinkDescription =
      "Didn't receive the link? Check your spam folder or request a new link in";
  static const String forgotPasswordTitle = "Reset your password";
  static const String weSendToYourEmailPart1Subtitle = "We sent a password reset link to";
  static const String weSendToYourEmailPart2Subtitle =
      "Check your inbox and follow the link to create a new password.";
  static const String forgotPasswordSubtitle =
      "Enter the email on your account and, and you will get the changing password link.";
  static const String registeredEmail = "Registered email";
  static const String codeExpiryNote = "The code expires after 10 minutes.";
  static const String sendLink = "Send link";
  static const String returnToSignIn = "Return to sign in";

  static const String newPassword = "New Password";
  static const String newPasswordHint = "Enter new password";
  static const String confirmNewPassword = "Confirm New Password";
  static const String confirmNewPasswordHint = "Re-enter new password";

  // Auth Validation & Status
  static const String nameRequired = "Please enter your name";
  static const String nameMinLength = "Name must be at least 2 characters";
  static const String emailRequired = "Please enter your email";
  static const String invalidEmail = "Please enter a valid email address";
  static const String passwordRequired = "Please enter your password";
  static const String passwordMinLength = "Password must be at least 6 characters";
  static const String confirmPasswordRequired = "Please confirm your password";
  static const String passwordsDoNotMatch = "Passwords do not match";
  static const String invalidCode = "Verification code must be 6 digits";
  static const String loginSuccess = "Welcome back!";
  static const String registrationSuccess = "Account created successfully!";
  static const String resetLinkSent = "Verification code sent to your email";
  static const String invalidCredentials = "Invalid email or password";
  static const String userAlreadyExists = "An account with this email already exists";
  static const String userNotFound = "No account found with this email";
  static const String networkError = "Network error. Please try again";

  // Profile Update
  static const String displayNameUpdated = "Display name updated successfully";
  static const String passwordUpdated = "Password updated successfully";
  static const String reauthenticateRequired = "Please log in again before making this change";
  static const String currentPasswordRequired = "Please enter your current password";
  static const String newDisplayNameRequired = "Please enter a display name";
  static const String newEmailRequired = "Please enter a new email";
  static const String newPasswordRequired = "Please enter a new password";

  // Change password / change email (Settings -> Account)
  static const String changePassword = "Change password";
  static const String changePasswordDesc = "Update the password you sign in with.";
  static const String changePasswordTitle = "Change your password";
  static const String changePasswordDialogDesc = "Confirm your current password, then choose a new one.";
  static const String currentPassword = "Current password";
  static const String currentPasswordHint = "Your password today";
  static const String samePasswordAsCurrent = "Pick a password different from your current one";

  static const String displayName = "Display name";
  static const String changeDisplayNameTitle = "Change your name";
  static const String changeDisplayNameDialogDesc =
      "This is the name shown on your profile. It changes nothing about how you sign in.";
  static const String newDisplayName = "Name";
  static const String newDisplayNameHint = "How you want to be called";
  static const String sameDisplayNameAsCurrent = "This is already your name";

  static const String changeEmail = "Change email";
  static const String changeEmailDesc = "Move your account to a different inbox.";
  static const String changeEmailTitle = "Change your email";
  static const String changeEmailDialogDesc =
      "We send a confirmation link to the new address. Your email changes only after you open that link.";
  static const String newEmail = "New email";
  static const String sameEmailAsCurrent = "This is already your email";
  static const String changeEmailLinkSent =
      "Confirmation link sent. Open it from your new inbox, then sign in again with the new email.";
  static const String saveChanges = "Save";

  // Logout
  static const String logout = "Log Out";
  static const String logoutConfirmTitle = "Log out of your account?";
  static const String logoutConfirmDesc =
      "You can sign back in anytime to continue your algorithmic journey.";
  static const String yesLogout = "Log Out";
  static const String notValidName = "Please enter a valid name";

  // Sync
  static const String syncNow = "Sync your progress";
  static const String syncSuccess = "Your progress is up to date.";
  static const String syncFailure = "Could not sync. Check your connection and try again.";
  static const String syncCooldownTitle = "Just a moment";
  static const String syncCooldownConfirm = "Got it";
  static const String syncHint = "Sync your data";

  /// Filled by [syncCooldownDesc]. Kept as its own constant so the Arabic table
  /// can key off the template rather than off a sentence with a number already
  /// baked into it.
  static const String syncCooldownDescTemplate =
      "Syncing is limited to once every 30 seconds. You can sync again in {seconds}s.";

  static String syncCooldownDesc(int seconds, {Translator tr = noTranslation}) {
    return _fill(tr(syncCooldownDescTemplate), <String, Object?>{'seconds': seconds});
  }

  // Settings screen
  static const String settings = "Settings";
  static const String settingsAccountSection = "Account";
  static const String settingsAppearanceSection = "Appearance";
  static const String themeSystem = "System";
  static const String themeSystemDesc = "Match your phone's setting";
  static const String themeLight = "Light";
  static const String themeLightDesc = "Always light";
  static const String themeDark = "Dark";
  static const String themeDarkDesc = "Always dark";
  static const String settingsLegalSection = "Legal";
  static const String settingsAboutSection = "About";
  static const String settingsSignedInAs = "Signed in as";
  static const String privacyPolicy = "Privacy Policy";
  static const String privacyPolicyDesc = "What AlgoDive stores, and why.";
  static const String termsOfService = "Terms of Service";
  static const String termsOfServiceDesc = "The rules for using AlgoDive.";
  static const String sourceCode = "Source code";
  static const String sourceCodeDesc = "AlgoDive is open source on GitHub.";
  static const String appVersionLabel = "Version";

  // Delete account
  static const String deleteAccount = "Delete account";
  static const String deleteAccountDesc = "Permanently erase your account and all its data.";
  static const String deleteAccountConfirmTitle = "Delete your account?";
  static const String deleteAccountConfirmDesc =
      "Your solved problems, streak and statistics will be erased for everyone and forever. This cannot be undone.";
  static const String deleteAccountContinue = "Continue";
  static const String deleteAccountPasswordTitle = "Confirm it's you";
  static const String deleteAccountPasswordDesc = "Enter your password to permanently delete this account.";
  static const String deleteAccountConfirmButton = "Delete Forever";
  static const String deleteAccountSuccess = "Your account has been deleted.";
  static const String deleteAccountWebNotice = "Can't sign in? Request deletion by email instead";

  // Contact / author links (Settings -> Contact)
  static const String settingsContactSection = "Contact";
  static const String contactEmail = "Email support";
  static const String contactGithub = "GitHub";
  static const String contactGithubDesc = "Follow the project and the author.";
  static const String contactLinkedIn = "LinkedIn";
  static const String contactLinkedInDesc = "Connect with the developer.";
  // static const String madeBy = "Made by Ahmed Abdo Elhawary";

  // Opening an external link
  static const String linkCouldNotOpen = "Couldn't open that link";
  static const String linkNoMailApp = "No mail app is set up on this device";

  // Legal
  static const String legalVersionPrefix = "Policy version";
  static const String deleteAccountHowItWorks = "How deletion works";
  static const String deleteAccountHowItWorksDesc = "What is erased, and how to request it by email.";

  // Sign up consent
  static const String signUpConsentPrefix = "By creating an account, you agree to our";
  static const String signUpConsentAnd = "and";

  // Guest session
  static const String guestProgressWarningTitle = "Replace your local progress?";
  static const String guestProgressWarningDesc =
      "Your local interactions will be removed when you log in to this account.";
  static const String continueToLogin = "Log In Anyway";
  static const String guestAccountTitle = "Log In or Sign Up";
  static const String guestAccountDesc = "Save your progress and sync it across your devices.";

  // Editor screen (Aurora screen 04)
  static const String runAndSubmit = "▸ Run & submit";
  static const String testCases = "TEST CASES";
  static const String gotPrefix = "→ got ";

  /// Takes a [BuildContext] because it *builds a sentence*.
  ///
  /// A plain constant is translated by the text widget that renders it, but
  /// this one is glued together first — `'12 / 15 passed'` is not a key in
  /// any table. So the word is translated on its own, then the numbers are
  /// placed around it. Every helper below follows the same rule.
  static String passedOfTotal(BuildContext context, int passed, int total) =>
      '$passed / $total${onboardingPassedWord.tr(context)}';

  // Onboarding (4 screens) — copy is fixed by the design spec, see
  // assets/onboarding/ONBOARDING_SPEC.md §3. Do not rewrite these strings.
  static const String onboardingSkip = "Skip";
  static const String onboardingNext = "Next";
  static const String onboardingGetStarted = "Get started";
  static const String onboardingContinueAsGuest = "Continue as guest";
  static const String onboardingGuestNote = "Guest progress moves to your account later";

  // 1 · See it
  static const String onboardingSeeItHeadline = "Algorithms, one step at a time.";
  static const String onboardingSeeItBody = "Every comparison and swap, shown as it happens.";
  static const String onboardingLegendCompare = "Compare";
  static const String onboardingLegendSwap = "Swap";
  static const String onboardingLegendSorted = "Sorted";
  static String onboardingCompareCaption(BuildContext context, int i, int a, int j, int b) =>
      '${compare.tr(context)} arr[$i]=$a ↔ arr[$j]=$b';

  // 2 · Explore it
  static const String onboardingExploreHeadline = "Draw a maze. Watch it get solved.";
  static const String onboardingExploreBody = "Drag walls, then watch the search find its way through.";
  static const String onboardingLegendVisited = "Visited";
  static const String onboardingLegendSearcher = searcher;
  static const String onboardingLegendPath = "Path";
  static String onboardingQueueCaption(BuildContext context, int waiting) =>
      '${searchRuleOldestFirst.tr(context)}$searchRuleSeparator$waiting ${searchWaiting.tr(context)}';

  static String onboardingStepCaption(BuildContext context, int step) => '${stepWord.tr(context)} $step';

  /// The bare word, so [onboardingStepCaption] has something to translate.
  /// [searchStepCounterTemplate] keeps its own full-sentence form because it
  /// carries two numbers, and Arabic puts them in the same order.
  static const String stepWord = "Step";

  // 3 · Write it
  static const String onboardingWriteHeadline = "100 challenges. Graded offline.";
  static const String onboardingWriteBody = "Your code runs on your device. Nothing leaves it.";
  static const String onboardingEditorFile = "two_sum.dart";
  static const String onboardingEditorLanguage = "Dart";
  static const String onboardingGradedOnDevice = "Graded on this device · no network";

  /// The count and the word are separate because the count rolls 0 -> 12 while
  /// "passed" only fades in once the run is finished.
  static String onboardingTestCount(int passed, int total) => '$passed / $total';
  static const String onboardingPassedWord = " passed";

  /// The sample shown in the onboarding editor card. Highlighted by matching
  /// whole words against [onboardingCodeKeywords] / [onboardingCodeFunction].
  static const String onboardingCodeSample = '''
class Solution {
  List<int> twoSum(List<int> nums, int target) {
    final seen = {};
    for (int i = 0; i < nums.length; i++) {
      if (seen.containsKey(target - nums[i]))
        return [seen[target - nums[i]], i];
      seen[nums[i]] = i;
    }
  }
}''';
  static const List<String> onboardingCodeKeywords = ["class", "final", "for", "if", "return"];
  static const String onboardingCodeFunction = "twoSum";

  // 4 · Track it
  static const String onboardingTrackHeadline = "See your streak grow.";
  static const String onboardingTrackBody = "Every solved problem lands on the grid the same day.";
  static const String onboardingDayStreak = "day streak";
  static const String onboardingSolved = "solved";
  static const String onboardingHeatLess = "Less";
  static const String onboardingHeatMore = "More";

  // Execution failures (007). The engine emits a stable `code` plus the
  // values involved and never a sentence — see `Failure` in the editor
  // package. These templates are where that pair becomes prose, and every
  // `{placeholder}` is filled in *after* the template is translated, so the
  // Arabic reads as Arabic rather than as English word order.
  static const String failureUndefinedVariable = "Undefined variable '{name}'";
  static const String failureUndefinedFunction = "Undefined function '{name}'";
  static const String failureIndexOutOfRange = "Index {index} is out of range for a list of length {length}";
  static const String failureKeyNotFound = "Key '{key}' was not found";
  static const String failureDivisionByZero = "Division by zero";
  static const String failureTypeMismatch = "Expected {expected} but got {actual}";
  static const String failureWrongArgumentCount = "Expected {expected} argument(s) but got {actual}";
  static const String failureUncaughtThrow = "Uncaught error: {message}";
  static const String failureUnsupportedConstruct = "'{construct}' isn't supported in this editor yet";
  static const String failureNotAvailableHere = "'{name}' isn't available in this environment";
  static const String failureMixedTabsAndSpaces =
      "This line mixes tabs and spaces, so its indentation is ambiguous";
  static const String failureUnexpectedIndent =
      "This line's indentation doesn't line up with any block above it";
  static const String failureInconsistentIndentation = "Inconsistent indentation";
  static const String failureCustomObjectsInThisLanguage =
      "This problem uses a linked list or tree, which the editor can only build in Dart so far";
  static const String failureMissingEntryPoint = "Couldn't find a function named '{name}' to run";
  static const String failureTimeLimit = "This ran for too long and was stopped";
  static const String failureMemoryLimit = "This used too much memory and was stopped";
  static const String failureRecursionLimit = "This recursed too deeply and was stopped";
  static const String failureCancelled = "Cancelled";
  static const String failureUnknown = "Something went wrong while running this code";

  /// The line that wraps the sentence above: `syntax error (line 4): ...`.
  static const String failureHeadlineTemplate = "{kind} error (line {line}): {message}";

  /// [FailureKind] names, as words rather than as identifiers.
  static const String failureKindSyntax = "syntax";
  static const String failureKindRuntime = "runtime";
  static const String failureKindUnsupported = "unsupported";
  static const String failureKindTimeLimit = "time limit";
  static const String failureKindMemoryLimit = "memory limit";
  static const String failureKindRecursionLimit = "recursion limit";
  static const String failureKindCancelled = "cancelled";

  /// Picks the template for an engine failure [code]. No substitution and no
  /// translation happen here — this is a pure `code -> template` map, which
  /// is what lets the caller translate *before* filling the blanks.
  static String executionFailureTemplate(String code, Map<String, Object?> data) {
    return switch (code) {
      'undefinedVariable' => failureUndefinedVariable,
      'undefinedFunction' => failureUndefinedFunction,
      'indexOutOfRange' => failureIndexOutOfRange,
      'keyNotFound' => failureKeyNotFound,
      'divisionByZero' => failureDivisionByZero,
      'typeMismatch' => failureTypeMismatch,
      'wrongArgumentCount' => failureWrongArgumentCount,
      'uncaughtThrow' => failureUncaughtThrow,
      'unsupportedConstruct' => failureUnsupportedConstruct,
      'notAvailableInThisEnvironment' => failureNotAvailableHere,
      'indentationError' => switch (data['reason']) {
          'mixedTabsAndSpaces' => failureMixedTabsAndSpaces,
          'unexpectedIndent' => failureUnexpectedIndent,
          _ => failureInconsistentIndentation,
        },
      'customObjectsInThisLanguage' => failureCustomObjectsInThisLanguage,
      'missingEntryPoint' => failureMissingEntryPoint,
      'timeLimitExceeded' => failureTimeLimit,
      'memoryLimitExceeded' => failureMemoryLimit,
      'recursionLimitExceeded' => failureRecursionLimit,
      'cancelled' => failureCancelled,
      _ => failureUnknown,
    };
  }

  /// Translates the [FailureKind] name. Unknown kinds fall through as-is.
  static String executionFailureKind(String kind, {Translator tr = noTranslation}) {
    final word = switch (kind) {
      'syntax' => failureKindSyntax,
      'runtime' => failureKindRuntime,
      'unsupported' => failureKindUnsupported,
      'timeLimit' => failureKindTimeLimit,
      'memoryLimit' => failureKindMemoryLimit,
      'recursionLimit' => failureKindRecursionLimit,
      'cancelled' => failureKindCancelled,
      _ => kind,
    };
    return tr(word);
  }

  /// Builds the sentence for an engine failure.
  ///
  /// Left at the default [Translator] the output is English, byte for byte
  /// what the old hard-coded `switch` produced — which is what the grading
  /// tests and the debug logs still read.
  static String executionFailureMessage(
    String code,
    Map<String, Object?> data, {
    Translator tr = noTranslation,
  }) {
    return _fill(tr(executionFailureTemplate(code, data)), data);
  }

  /// The whole line, kind and line number included.
  static String executionFailureHeadline({
    required String kind,
    required int line,
    required String code,
    required Map<String, Object?> data,
    Translator tr = noTranslation,
  }) {
    return _fill(tr(failureHeadlineTemplate), <String, Object?>{
      'kind': executionFailureKind(kind, tr: tr),
      'line': line,
      'message': executionFailureMessage(code, data, tr: tr),
    });
  }

  /// Replaces every `{key}` in [template] with `data[key]`.
  ///
  /// A placeholder with no matching entry is left alone rather than printed
  /// as `null` — a half-filled sentence is still readable, `null` is not.
  static String _fill(String template, Map<String, Object?> data) {
    return template.replaceAllMapped(RegExp(r'\{([a-zA-Z]+)\}'), (match) {
      final value = data[match.group(1)];
      return value == null ? match.group(0)! : '$value';
    });
  }
}
