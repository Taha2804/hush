# How to run Hushbug

All commands are run from the project folder in PowerShell:

```powershell
cd C:\Users\badam\Desktop\hushbug
```

First time only (or after pulling changes), fetch packages:

```powershell
flutter pub get
```

---

## Android

### Option A: Emulator (no phone needed)

1. **Start the emulator.** Use either of these:
   - Android Studio → **Device Manager** → press ▶ next to **Hushbug_Pixel**, or
   - from PowerShell:
     ```powershell
     & "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Hushbug_Pixel
     ```
2. Wait until the Android home screen appears, then check that it's connected:
   ```powershell
   flutter devices        # should list emulator-5554
   ```
3. **Run the app:**
   ```powershell
   flutter run --release
   ```
   - The first build takes a few minutes. Later builds are faster.
   - While it's running, press `q` in the terminal to quit.

**If `flutter run` hangs or fails to attach**, this machine sometimes has that problem. Build the APK and install it directly instead:

```powershell
flutter build apk --release --target-platform android-x64
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb install -r build\app\outputs\flutter-apk\app-release.apk
& $adb shell am start -n com.hushbug.hushbug/.MainActivity
```

### Option B: Your own Android phone

1. **Turn on Developer options on the phone:** Settings → About phone → tap **Build number** 7 times.
2. Settings → Developer options → turn on **USB debugging**.
3. Plug the phone into the PC and tap **Allow** on the prompt that appears on the phone.
4. Check that the phone shows up:
   ```powershell
   flutter devices
   ```
5. Run the app:
   ```powershell
   flutter run --release
   ```

### Option C: Share an APK file (no cable, no PC needed later)

1. Build the APK:
   ```powershell
   flutter build apk --release
   ```
2. Copy `build\app\outputs\flutter-apk\app-release.apk` to the phone, for example over WhatsApp, Google Drive or USB.
3. Open the file on the phone.
4. When asked, allow **Install unknown apps** for the app you opened it from.

> Use the plain `flutter build apk --release` command for phones. Builds made with `--target-platform android-x64` only run on the emulator.

> **Black screenshots during a game are normal.** The app blocks screenshots and screen recording while the secret cards are on screen, so nobody can peek.

---

## Windows

Windows builds need **Visual Studio 2022** with its C++ tools. This PC doesn't have them yet. VS Code is a different program and isn't enough on its own.

### One-time setup

1. Download **Visual Studio 2022 Community** (free) from https://visualstudio.microsoft.com/.
2. In the installer, tick **"Desktop development with C++"** and install. It's roughly 8 GB.
3. Check the setup:
   ```powershell
   flutter doctor
   ```
   The **Visual Studio** line should now show a ✓.
4. Make sure Windows desktop support is on. It's already enabled on this PC:
   ```powershell
   flutter config --enable-windows-desktop
   ```

### Run it

```powershell
flutter run -d windows --release
```

### Make a standalone build

```powershell
flutter build windows --release
```

- The app ends up in `build\windows\x64\runner\Release\`.
- Double-click `hushbug.exe` to start it.
- To give it to someone else, copy the **whole `Release` folder**. The `.exe` won't run without the DLLs and the `data` folder next to it.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `No devices found` | Start the emulator, or plug in the phone and accept USB debugging. Then run `flutter devices` again. |
| Emulator won't start | In Android Studio → Device Manager, **Cold Boot** Hushbug_Pixel, or **Wipe Data** if that doesn't help. |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Uninstall the old version first: `adb uninstall com.hushbug.hushbug` |
| Build errors after changing code | `flutter clean`, then `flutter pub get`, then try again. |
| Windows: "Unable to find suitable Visual Studio toolchain" | Install the "Desktop development with C++" workload (see above). |
| Online Search says no internet | Check that the emulator or PC is online. Offline Packs always work. |

## Useful extra commands

```powershell
flutter test        # run all 82 tests
flutter analyze     # check the code for problems
flutter doctor -v   # full report of what's installed
```
