import 'package:hive/hive.dart';
import 'enums.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 5)
class AppSettings {
  // Mode de thème de l'app
  @HiveField(0)
  final AppThemeMode themeMode;

  // Notifications activées/désactivées
  @HiveField(1)
  final bool notificationsEnabled;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.notificationsEnabled = true,
  });
}