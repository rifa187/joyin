# Repository Guidelines

## Project Structure & Module Organization
- lib/main.dart wires routing and Firebase; feature code lives in lib/auth, lib/dashboard, lib/onboarding, and lib/profile with local widgets/ or providers/ folders when needed.
- Shared contracts stay under lib/core, helpers under lib/utils, reusable UI under lib/widgets; localization ARB files sit in lib/l10n and generated strings in lib/gen_l10n.
- Tests mirror the feature layout inside 	est/<feature>/. Platform shells (ndroid/, ios/, web/, macos/, linux/, windows/) stay slim, while media/fonts belong in ssets/ and must be declared in pubspec.yaml.

## Build, Test, and Development Commands
- lutter pub get installs dependencies whenever pubspec.yaml or generated Firebase files change.
- lutter analyze enforces nalysis_options.yaml; do not merge with warnings.
- lutter test --coverage runs all Dart tests and writes coverage/lcov.info for CI dashboards.
- lutter run -d chrome (web) or lutter run -d emulator-5554 (Android) give fast smoke tests; use lutter build apk --release / lutter build ios --release before tagging builds.

## Coding Style & Naming Conventions
- Stick to 2-space indentation, trailing commas on multiline widgets, and dart format . before committing.
- Use PascalCase for widgets/classes, lowerCamelCase for members, SCREAMING_SNAKE_CASE only for shared constants, and snake_case.dart filenames (for example user_profile_view.dart, user_profile_view_test.dart).
- The repo inherits lutter_lints; avoid blanket ignores, centralize shared widgets in lib/widgets, and move user-facing strings into the localization ARB files.

## Testing Guidelines
- Target >80% coverage; every provider, formatter, and widget with branches needs a 	est/<feature>/<name>_test.dart.
- Group specs by behavior (group('renders empty state', ...)) and prefer local fixtures over live Firebase or HTTP calls.
- Mock network/services in tests and rerun lutter test --coverage before pushing.

## Commit & Pull Request Guidelines
- This checkout ships without .git, but upstream uses Conventional Commits (eat:, ix:, chore:, docs:). Keep subjects imperative and wrap optional bodies at 72 chars.
- Commits stay atomic and include generated outputs such as pubspec.lock or lib/gen_l10n.
- PRs must state the problem, the fix, verification commands, linked issue, and screenshots/gifs for UI updates. Tag platform owners when touching platform folders and wait for analyzer + test jobs to pass.

## Security & Configuration Tips
- Regenerate lib/firebase_options.dart via lutterfire configure; never hand-edit secrets.
- Document new --dart-define keys or service dependencies in README.md plus the release checklist so other agents can reproduce builds.

