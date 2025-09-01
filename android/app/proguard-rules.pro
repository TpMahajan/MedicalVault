## Flutter related classes ko keep karo
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Share Plus plugin
-keep class dev.fluttercommunity.plus.share.** { *; }

## File Picker plugin
-keep class com.mr.flutter.plugin.filepicker.** { *; }

## Kotlin coroutines (kabhi kabhi strip ho jati hain)
-keep class kotlinx.coroutines.** { *; }

## Prevent stripping of annotation classes
-keepattributes *Annotation*
