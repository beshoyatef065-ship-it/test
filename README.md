# تطبيق أقرب كنيسة (Flutter + Google Places API)

تطبيق بسيط يجيب موقعك الحالي عبر GPS، يبحث عن أقرب الكنايس باستخدام
Google Places API، ويعرضهم في قائمة مرتبة من الأقرب للأبعد مع زرار
يفتح لك الاتجاهات في تطبيق Google Maps.

---

## 1) إعداد المشروع

الملفات اللي وصلتك دي هي الكود فقط (لib و pubspec.yaml). تحتاج تدمجها
داخل مشروع Flutter جديد:

```bash
flutter create nearest_church
cd nearest_church
```

بعد كده:
- استبدل ملف `pubspec.yaml` بالملف اللي بعتهولك
- استبدل مجلد `lib/` بالكامل بالمجلد اللي بعتهولك
- شغّل: `flutter pub get`

---

## 2) الحصول على مفتاح Google Places API

1. روح لـ [Google Cloud Console](https://console.cloud.google.com/)
2. أنشئ مشروع جديد (أو استخدم مشروع موجود)
3. من القائمة فعّل **Places API**
4. فعّل الـ **Billing** على المشروع (لازم تفعيله حتى لو هتفضل في الحد المجاني الشهري)
5. من **Credentials** أنشئ **API Key**
6. حط المفتاح في ملف `lib/services/places_service.dart` بدل:
   ```dart
   static const String _apiKey = 'YOUR_GOOGLE_PLACES_API_KEY';
   ```

⚠️ **مهم جداً للأمان**: متسيبش المفتاح ده عريان في كود تطبيق هتنشره على
المتجر. قيّد المفتاح من Google Cloud Console بـ:
- Application restrictions → Android apps (حط SHA-1 + package name بتاعك)
- API restrictions → Places API بس

---

## 3) صلاحيات الموقع

### Android
في ملف `android/app/src/main/AndroidManifest.xml` ضيف السطرين دول
جوه `<manifest>` وقبل `<application>`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS
في ملف `ios/Runner/Info.plist` ضيف:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>التطبيق محتاج موقعك عشان يلاقي أقرب كنيسة منك</string>
```

---

## 4) التشغيل

```bash
flutter run
```

---

## 5) ملاحظة عن دقة البيانات في مصر

اخترت Google Places API كمصدر بيانات. ده سريع وتلقائي، بس زي ما هو
متوقع - تغطيته للكنايس في مصر مش دايماً كاملة أو دقيقة 100% (أسماء
ناقصة، كنايس مش مسجلة، إلخ). لو حسيت إن النتايج ضعيفة في منطقتك،
أسهل حل وسط هو:

- تسيب الـ Places API يجيب نتايج تلقائية كأساس
- وتعمل قائمة يدوية (JSON بسيط أو قاعدة بيانات صغيرة) للكنايس المعروفة
  في الغردقة مثلاً، وتدمجها مع نتايج الـ API في الشاشة

لو عايز، أقدر أضيفلك ده كخطوة تالية (مصدر بيانات Hybrid).

---

## بنية الملفات

```
lib/
 ├── main.dart                     # نقطة دخول التطبيق
 ├── models/
 │    └── church.dart              # موديل بيانات الكنيسة
 ├── services/
 │    ├── location_service.dart    # جلب موقع المستخدم (GPS)
 │    └── places_service.dart      # الاتصال بـ Google Places API
 └── screens/
      └── home_screen.dart         # شاشة العرض + الترتيب بالمسافة
```
