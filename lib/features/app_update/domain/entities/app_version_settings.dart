class AppVersionSettings {
  final int minVersion;
  final int latestVersion;
  final String message;

  const AppVersionSettings({
    required this.minVersion,
    required this.latestVersion,
    required this.message,
  });
}