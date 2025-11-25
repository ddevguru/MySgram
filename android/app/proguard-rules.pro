# Razorpay rules
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Rules for other plugins
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Add specific rules for other plugins if needed
-keep class app.meedu.flutter_facebook_auth.** { *; }
-dontwarn app.meedu.flutter_facebook_auth.**
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**
-keep class io.github.ponnamkarthik.toast.fluttertoast.** { *; }
-dontwarn io.github.ponnamkarthik.toast.fluttertoast.**
# Add similar rules for other plugins as needed