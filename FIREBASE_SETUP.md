# راهنمای تنظیم Firebase برای مانا

## مراحل نصب و راه‌اندازی Firebase

### 1. ایجاد پروژه Firebase

1. به [Firebase Console](https://console.firebase.google.com/) بروید
2. روی "Add project" کلیک کنید
3. نام پروژه را وارد کنید (مثلاً `mana-ai-assistant`)
4. Google Analytics را فعال کنید (اختیاری)
5. پروژه را ایجاد کنید

### 2. اضافه کردن اپلیکیشن Android

1. در Firebase Console، روی آیکون Android کلیک کنید
2. Package name را وارد کنید (از `android/app/build.gradle` بگیرید)
3. App nickname را وارد کنید
4. `google-services.json` را دانلود کنید
5. فایل را در `android/app/` قرار دهید

### 3. اضافه کردن اپلیکیشن iOS

1. در Firebase Console، روی آیکون iOS کلیک کنید
2. Bundle ID را وارد کنید (از `ios/Runner.xcodeproj` بگیرید)
3. App nickname را وارد کنید
4. `GoogleService-Info.plist` را دانلود کنید
5. فایل را در `ios/Runner/` قرار دهید

### 4. فعال‌سازی Authentication

1. در Firebase Console، به **Authentication** بروید
2. روی **Get started** کلیک کنید
3. در تب **Sign-in method**:
   - **Google**: فعال کنید و Email و Project support email را تنظیم کنید
   - **Apple**: فعال کنید (فقط برای iOS)

### 5. تنظیم Firestore Database

1. در Firebase Console، به **Firestore Database** بروید
2. روی **Create database** کلیک کنید
3. حالت **Test mode** را انتخاب کنید (برای شروع)
4. Location را انتخاب کنید (مثلاً `us-central1`)
5. Database را ایجاد کنید

### 6. تنظیم قوانین امنیتی Firestore

در Firebase Console > Firestore Database > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // کاربران فقط به داده‌های خودشان دسترسی دارند
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /chats/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /messages/{messageId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    match /tasks/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /user_preferences/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /user_behaviors/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /actions/{actionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### 7. تنظیمات Android

#### 7.1. اضافه کردن dependency

در `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

در `android/app/build.gradle` (در انتها):
```gradle
apply plugin: 'com.google.gms.google-services'
```

#### 7.2. تنظیم minSdkVersion

در `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### 8. تنظیمات iOS

#### 8.1. نصب CocoaPods

```bash
cd ios
pod install
cd ..
```

#### 8.2. تنظیم Sign in with Apple

1. در [Apple Developer](https://developer.apple.com/) بروید
2. App ID را ایجاد/ویرایش کنید
3. "Sign in with Apple" capability را فعال کنید
4. در Xcode، به Target > Signing & Capabilities بروید
5. "+ Capability" را بزنید و "Sign in with Apple" را اضافه کنید

### 9. تست اتصال

```dart
// در main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ManaApp());
}
```

### 10. ساختار Firestore

پس از راه‌اندازی، ساختار زیر در Firestore ایجاد می‌شود:

```
users/
  {userId}/
    - name, ageGroup, dailyActivity, etc.
    
chats/
  {userId}/
    messages/
      {messageId}/
        - text, isUser, timestamp, etc.
        
tasks/
  {userId}/
    {taskId}/
      - title, description, dueDate, etc.
      
user_preferences/
  {userId}/
    - preferredTone, interests, habits, etc.
    
user_behaviors/
  {userId}/
    actions/
      {actionId}/
        - action, context, timestamp
```

## نکات مهم

⚠️ **امنیت**: حتماً قوانین Firestore را تنظیم کنید تا فقط کاربران به داده‌های خودشان دسترسی داشته باشند.

🔑 **API Keys**: فایل‌های `google-services.json` و `GoogleService-Info.plist` را در `.gitignore` قرار دهید.

📱 **تست**: قبل از انتشار، حتماً Authentication و Firestore را تست کنید.

## عیب‌یابی

### مشکل: Firebase initialize نمی‌شود
- بررسی کنید که فایل‌های `google-services.json` و `GoogleService-Info.plist` درست قرار گرفته‌اند
- `flutter clean` و `flutter pub get` را اجرا کنید

### مشکل: Google Sign In کار نمی‌کند
- SHA-1 fingerprint را در Firebase Console اضافه کنید:
  ```bash
  # Android
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```

### مشکل: Apple Sign In کار نمی‌کند
- مطمئن شوید که در Apple Developer Console تنظیم شده است
- Bundle ID باید با Firebase یکسان باشد

---

موفق باشید! 🚀

