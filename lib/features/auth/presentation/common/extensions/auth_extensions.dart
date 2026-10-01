extension AuthExtensionsX on String {
  bool get validateEmail {
    // Loose on purpose: plus-addresses and long domains are real, and Firebase makes the final call.
    final emailRegex = RegExp(r'^[\w.%+-]+@([\w-]+\.)+[A-Za-z]{2,}$');
    return emailRegex.hasMatch(trim());
  }
}
