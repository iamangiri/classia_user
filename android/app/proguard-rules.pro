# Proguard rules for Flutter app

# Ignore missing classes that are optional dependencies
-dontwarn com.google.android.apps.nbu.paisa.**
-dontwarn com.google.android.play.core.**
-dontwarn com.razorpay.**

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Razorpay ProGuard annotations fix
-keep class proguard.annotation.Keep
-keep class proguard.annotation.KeepClassMembers
-keepclassmembers class * {
    @proguard.annotation.Keep *;
}
-keepclassmembers class * {
    @proguard.annotation.KeepClassMembers *;
}

# Keep Razorpay classes
-keep class com.razorpay.** { *; }
-keepclassmembers class com.razorpay.** { *; }

# Google Play Services - Gpay/Wallet classes (optional dependency)
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
-keepclassmembers class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }

# Google Play Core - Split Install classes (optional dependency)
-keep class com.google.android.play.core.** { *; }
-keepclassmembers class com.google.android.play.core.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep Activity, Service, BroadcastReceiver, ContentProvider classes
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.Fragment
-keep public class * extends androidx.fragment.app.Fragment
-keep public class * extends android.preference.Preference

# Keep View constructors for inflation from XML
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}