

# Keep Enum Values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Prevent Obfuscation for Gson
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

-keep class com.ryanheise.just_audio.** { *; }
