# Flutter's own rules are applied by the Flutter Gradle plugin. These cover
# the native libraries this app bundles.

# sqlite3_flutter_libs / drift load the native SQLite library by name.
-keep class org.sqlite.** { *; }
-keep class io.flutter.plugins.** { *; }
