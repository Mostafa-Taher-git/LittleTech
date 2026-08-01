# Screenshots Placeholder

Add your app screenshots here for the README to display.

## Required Screenshots

| File | Description | Suggested Size |
|------|-------------|----------------|
| `splash.png` | Splash screen | 1080×1920 |
| `home.png` | World selection screen | 1080×1920 |
| `level.png` | Level gameplay screen | 1080×1920 |
| `boss.png` | Boss battle screen | 1080×1920 |
| `customize.png` | Customization screen | 1080×1920 |
| `solutions.png` | Solutions library | 1080×1920 |
| `settings.png` | Settings screen | 1080×1920 |

## How to Capture

```bash
# Android (connected device)
adb exec-out screencap -p > docs/screenshots/home.png

# iOS (simulator)
xcrun simctl io booted screenshot docs/screenshots/home.png

# Flutter integration test (automated)
flutter drive --target=test_driver/screenshots.dart
```

## Guidelines

- Use **light theme** for consistency
- Capture on **phone** (not tablet/desktop)
- Hide **navigation gestures** / status bar if possible
- Use **real content** (not empty states)
- Compress: `pngquant --quality=80-90 *.png`

## Placeholder

Until real screenshots are added, the README will show broken image links. Replace this folder's contents with actual captures.