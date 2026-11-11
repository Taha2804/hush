# Hushbug invite page

A static site that makes `https://<your-domain>/invite/CODE` work:

- **App installed (Android):** the verified App Link opens Hushbug straight onto the invitation screen.
- **App not installed:** this page sends the player to Google Play with `referrer=invite=CODE`. On first launch the app reads it back (Play Install Referrer) and shows the same invitation, even across sign-in.

## Setup

1. Deploy this folder to a domain you control, for example with Vercel: `npx vercel deploy --prod` from this folder, then add your domain in the Vercel dashboard.
2. Put your signing certificate fingerprints in `.well-known/assetlinks.json`:
   - your upload key: `keytool -list -v -keystore <your.jks> -alias <alias>`
   - the Play App Signing key: Play Console > Setup > App integrity.
3. Build the app with your domain:
   `flutter build appbundle --dart-define=INVITE_BASE_URL=https://your-domain -PinviteHost=your-domain`
4. Check verification on a phone: `adb shell pm get-app-links com.hushbug.hushbug`.

The Play Store part only works once Hushbug is published on Google Play (internal testing is enough to try it).

## iOS

Universal Links need an Apple Developer account: add the Associated Domains capability `applinks:your-domain` in Xcode and host `.well-known/apple-app-site-association`. There is no install referrer on iOS, so a player who installs from the App Store enters the code shown on this page.
