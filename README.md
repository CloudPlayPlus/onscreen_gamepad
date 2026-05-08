# onscreen_gamepad

Flutter onscreen gamepad overlay prototype for CloudPlayPlus.

The package currently contains:

- a pure Dart layout engine for the five-zone screen button rules;
- an Xbox default profile;
- a Flutter overlay widget that only hit-tests real buttons, leaving empty
  overlay space pass-through;
- an example app for checking phone, foldable, tablet, and desktop layouts.

## Layout rules

See [docs/screen_button_layout.md](docs/screen_button_layout.md) for the current
formula, default parameters, size tiers, and Xbox default control table.

## Demo

```sh
cd example
flutter run -d chrome
```

The demo uses the public package API from `package:onscreen_gamepad`.
