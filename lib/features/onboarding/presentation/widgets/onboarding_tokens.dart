import 'package:algorithm_visualizer/core/resources/theme_manager.dart';

/// Design tokens for the onboarding flow.
///
/// The spec (`assets/onboarding/ONBOARDING_SPEC.md` §2) lists raw dark-theme
/// hexes. Every one of them is re-expressed here as the [ThemeEnum] role that
/// already carries that exact value in the dark palette, so the flow renders in
/// both themes without a second set of colours:
///
/// | spec token        | ThemeEnum          | dark      | light     |
/// |-------------------|--------------------|-----------|-----------|
/// | ground `#0B0B0D`  | [bgBase]           | `0B0B0D`  | `FBFBFC`  |
/// | surface `#181A1F` | [surface]          | `181A1F`  | `F4F5F7`  |
/// | hairline `#23262B`| [hairline]         | `24262C`  | `DCDEE3`  |
/// | border `#2A2E35`  | [border]           | `3A3D46`  | `B9BCC4`  |
/// | textHi `#F2F3F5`  | [textHi]           | `F2F3F5`  | `101114`  |
/// | textBody `#9A9FAB`| [textBody]         | `9A9FAB`  | `4A4F5A`  |
/// | white accent      | [accent]           | `FFFFFF`  | `12141C`  |
/// | sand `#D9AE72`    | [sand]             | `D9AE72`  | `8A5D12`  |
/// | blue `#72A8D9`    | [blue]             | `72A8D9`  | `12518A`  |
/// | green `#79C9A4`   | [green]            | `79C9A4`  | `11704E`  |
/// | rose `#DE8189`    | [rose]             | `DE8189`  | `A83F49`  |
///
/// Two values are deliberately a shade off the spec because no existing role
/// carries the exact hex and adding one would fork the palette: `hairline`
/// resolves to `24262C` (spec `23262B`) and `border` to `3A3D46`
/// (spec `2A2E35`, so button outlines read one step stronger).
abstract final class OnboardingTokens {
  /// ---- colour roles ----
  static const ThemeEnum bgBase = ThemeEnum.bgBase;
  static const ThemeEnum surface = ThemeEnum.surfaceRaised;
  static const ThemeEnum hairline = ThemeEnum.border;
  static const ThemeEnum border = ThemeEnum.borderStrong;
  static const ThemeEnum textHi = ThemeEnum.textPrimary;
  static const ThemeEnum textBody = ThemeEnum.textBody;

  /// The one interactive colour — white on dark, ink on light.
  static const ThemeEnum accent = ThemeEnum.accent;

  /// Label that sits on top of an [accent] fill.
  static const ThemeEnum onAccent = ThemeEnum.onPrimary;

  /// Screen accents, in story order: white → blue → green → sand.
  static const ThemeEnum sand = ThemeEnum.accentYellow;
  static const ThemeEnum blue = ThemeEnum.barTarget;
  static const ThemeEnum green = ThemeEnum.accentGreen;
  static const ThemeEnum rose = ThemeEnum.accentRed;

  /// Idle sorting bar / unvisited grid cell.
  static const ThemeEnum idle = ThemeEnum.barIdle;

  /// 3 px progress track under the step caption.
  static const ThemeEnum track = ThemeEnum.track;

  /// Code syntax — keywords sand, everything else body grey.
  static const ThemeEnum codeKeyword = ThemeEnum.codeKeyword;
  static const ThemeEnum codePlain = ThemeEnum.codePlain;

  /// ---- geometry (spec §2) ----
  static const double screenPadding = 22;
  static const double headerHeight = 44;
  static const double markSize = 26;
  static const double cardRadius = 14;
  static const double buttonHeight = 52;
  static const double buttonRadius = 12;
  static const double cardToHeadline = 34;
  static const double headlineToBody = 12;

  /// The controls strip is one box whose height is interpolated between these
  /// two as you swipe onto the last page, so it grows with your finger instead
  /// of snapping when the page settles.
  static const double footerSingle = buttonHeight;
  static const double footerDual = buttonHeight * 2 + 10 * 2 + 24;

  /// ---- type (spec §2) ----
  static const double headlineSize = 30;
  static const double headlineHeight = 1.1;
  static const double headlineTracking = -0.6;
  static const double bodySize = 15;
  static const double bodyHeight = 1.5;
  static const double monoSize = 12;
  static const double buttonLabelSize = 17;
}
