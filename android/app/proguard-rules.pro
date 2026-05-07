# حفظ كلاسات Stripe من الحذف (Tree Shaking)
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# حل مشكلة الـ Push Provisioning اللي ظاهرة في الـ Error
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# قوانين عامة لضمان استقرار المكتبات الخارجية
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**