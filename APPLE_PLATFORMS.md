# Building NekoTan for Apple Platforms (iOS/iPadOS/macOS)

This document provides instructions for building and running NekoTan on Apple platforms.

## Requirements

- Xcode 14.0 or later
- iOS 15.0+ / macOS 12.0+
- Swift 6.1 or later

## Project Structure

The project has been structured to support Apple platforms with the following components:

- `NekoTanLib`: A shared library target containing all core functionality
- Platform-specific code in dedicated directories:
  - `iOS`: iOS-specific code and resources
  - `macOS`: macOS-specific code and resources
- Shared resources including fonts in the `fonts` directory

## Building for iOS/iPadOS

1. Open the project in Xcode:
   ```
   open NekoTan.xcodeproj
   ```

2. Select the iOS target and your desired device/simulator

3. Build and run (⌘R)

## Building for macOS

1. Open the project in Xcode:
   ```
   open NekoTan.xcodeproj
   ```

2. Select the macOS target

3. Build and run (⌘R)

## Custom Fonts

The application uses the KleeOne-Regular font which is automatically registered at startup. The font files are included in the bundle resources.

## Troubleshooting

### Font Registration Issues

If fonts are not displaying correctly:

1. Check the console for font registration messages
2. Verify that the fonts are correctly included in the bundle
3. Try manually registering the fonts using the Font.registerCustomFonts() method

### Build Errors

If you encounter build errors:

1. Ensure you have the correct Xcode version
2. Update to the latest Swift toolchain
3. Clean the build folder (Shift+⌘+K) and rebuild

## Distribution

To prepare for App Store submission:

1. Update the bundle identifier in the project settings
2. Configure signing certificates
3. Build an archive (Product > Archive)
4. Submit through App Store Connect