# upi_intent_cred 💸

A patched fork of [`upi_intent`](https://pub.dev/packages/upi_intent) by [Yash Dodani](https://github.com/Yash-Dodani), published as a standalone package with the original author's MIT license.

[![pub.dev](https://img.shields.io/pub/v/upi_intent_cred.svg)](https://pub.dev/packages/upi_intent_cred)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![platform](https://img.shields.io/badge/platform-android%20%7C%20ios-green)](https://pub.dev/packages/upi_intent_cred)

---

## Changes in this fork

| Change | Details |
|--------|---------|
| ✅ CRED detection on iOS | Added `credpay://upi` scheme probe |
| ✅ Google Pay scheme fix on iOS | Changed `gpay://` to `gpay://upi` for reliable detection |
| ✅ Swift Package Manager support | Added `Package.swift` alongside existing CocoaPods support |

---

## iOS setup — required schemes

Add these to your app's `Info.plist` under `LSApplicationQueriesSchemes`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>gpay</string>
  <string>phonepe</string>
  <string>paytmmp</string>
  <string>credpay</string>
  <string>bhim</string>
  <string>amazonpay</string>
  <string>amznmobile</string>
  <string>upi</string>
</array>
```

---

## Android setup — required

See the original package's [Android setup](https://pub.dev/packages/upi_intent#step-2--android-setup-️-required) for the `<queries>` block.

---

## Usage

Identical to `upi_intent`. Replace the import:

```dart
import 'package:upi_intent_cred/upi_intent.dart';
```

All APIs (`UpiIntent.pay`, `UpiIntent.getInstalledApps`, `UpiPayment`, `UpiResponse`, `UpiValidator`) are unchanged.

---

## Installation

```yaml
dependencies:
  upi_intent_cred: ^1.0.1
```

---

## License

MIT — see [LICENSE](LICENSE).  
Original work: Copyright (c) 2026 Dodani Yash.  
Modifications: Copyright (c) 2026 Eishal Cyril.

---

## Credits

Built on top of [`upi_intent`](https://pub.dev/packages/upi_intent) by [Yash Dodani](https://github.com/Yash-Dodani). Patches contributed back where possible.
