import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Look-up-table localisation, where **the English text is the key**.
///
/// The alternative — `flutter gen-l10n` with `.arb` files — was not taken, and
/// the reason is [StringsManager]: its 340-odd constants are `static const`
/// and are read inside `const` constructors all over the tree
/// (`const SectionHeader(title: StringsManager.settings)`). A generated
/// `AppLocalizations.of(context).settings` needs a [BuildContext], so every
/// one of those call sites would lose its `const` — a large diff that also
/// costs the framework the const-canonicalisation it currently gets for free.
///
/// So the English string stays the key, exactly as
/// `strings_manager.dart`'s own header comment always said it would, and only
/// the leaf text widgets do the look-up.
///
/// A missing key is not an error: [tr] returns the source string. That is what
/// keeps the untranslated half of the app readable while the Arabic table
/// grows, and it is what makes translating an already-Arabic string a no-op —
/// which in turn makes [tr] safe to apply twice.
/// A translation function, so a **pure** helper can localise without taking a
/// [BuildContext].
///
/// The status-line builders under `features/visualize/` are documented as
/// pure — no context, no provider reads — and that is worth keeping: it is
/// why they can be unit-tested with a plain `SortStep` and no widget tree.
/// Handing them a [Translator] keeps that property. The widget that has the
/// context supplies `AppLocalizations.of(context).tr`; a test supplies
/// nothing and gets English.
typedef Translator = String Function(String source);

/// The default [Translator]: English is its own translation.
String noTranslation(String source) => source;

@immutable
class AppLocalizations {
  const AppLocalizations(this.locale, this._table);

  final Locale locale;
  final Map<String, String> _table;

  /// English needs no table: every key already *is* its English text.
  static const AppLocalizations _english = AppLocalizations(Locale('en'), <String, String>{});

  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ar')];

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// Falls back to English rather than throwing, so a widget built outside a
  /// `MaterialApp` (a golden test, a standalone `WidgetsApp`) still renders.
  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ?? _english;

  bool get isArabic => locale.languageCode == 'ar';

  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

  String tr(String source) => _table[source] ?? source;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  /// [SynchronousFuture] is the whole reason switching language does not
  /// flash. `Localizations` awaits this future before it swaps its table in;
  /// a real `Future` would leave the old locale on screen for a frame, a
  /// synchronous one resolves inside the same build and the new language is
  /// simply there on the next frame.
  @override
  Future<AppLocalizations> load(Locale locale) {
    ///TODO: handle arabic overlay
    // final table = locale.languageCode == 'ar' ? kArTranslations : const <String, String>{};
    const table = <String, String>{};
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale, table));
  }

  /// The tables are compile-time constants, so a reload can never produce
  /// anything different.
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension TranslateExtension on String {
  /// Translates this string into the locale of [context].
  ///
  /// Reach for this only where a sentence is *assembled* before it reaches a
  /// text widget — a template with placeholders, or fragments joined with
  /// `$`. Plain labels need nothing: the adaptive text widgets already call
  /// [AppLocalizations.tr] on whatever they are given.
  String tr(BuildContext context) => AppLocalizations.of(context).tr(this);
}
