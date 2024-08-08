
class HashCode {
  static String generateIdentifier(List<String> userIds) {
    userIds.sort();

    String concatenatedIds = userIds.join(',');

    int checksum = 0;
    for (int i = 0; i < concatenatedIds.length; i++) {
      checksum += concatenatedIds.codeUnitAt(i) * (i + 1);
    }

    String hexString = checksum.toRadixString(16);

    String uniqueString = hexString.substring(0, hexString.length.clamp(0, 32));

    return uniqueString;
  }
}
