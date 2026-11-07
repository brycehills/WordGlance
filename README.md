# WordGlance

WordGlance is an iPhone vocabulary app for building a small Japanese-learning habit throughout the day. It places the current JLPT word on a Home Screen or Lock Screen widget, then opens into a focused review experience when you have a moment.

## What it does

- Guides a learner through Japanese level, goal, active hours, and reminder preferences.
- Shows a level-specific Japanese word in a WidgetKit widget.
- Keeps the widget and Today screen on the same current word.
- Provides a flashcard-style review, a separate multiple-choice Practice mode, a browsable deck Collection, and an activity Profile.
- Includes N5–N1 starter decks. Katakana-only loanwords are excluded from the learning rotation.

## Requirements

- macOS with Xcode 26 or later
- An iPhone running iOS 26 or later for on-device widget testing
- An Apple ID signed into Xcode (a free Personal Team is enough for personal-device testing)

## Run it locally

1. Open `WordGlance.xcodeproj` in Xcode.
2. In the scheme picker, choose **WordGlance** and your connected iPhone.
3. Select your Apple ID under **Signing & Capabilities** for both the app and widget extension.
4. Confirm both targets use the App Group `group.com.brycehills.WordGlance`.
5. Press **Run**.
6. On the iPhone, add the WordGlance widget from the Home Screen or Lock Screen customization menu.

## Project structure

```text
WordGlance/                 Main SwiftUI iPhone app
WordGlanceWidget/           WidgetKit extension
WordGlance/WordBank.swift   App vocabulary and shared App Group settings
WordGlanceWidget/WordBank.swift
                            Mirrored vocabulary/settings used by the widget
```

## Vocabulary data and attribution

The starter vocabulary comes from [OpenJLPT](https://github.com/evanclan/OpenJLPT), licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). WordGlance includes in-app attribution. If this project is distributed or its vocabulary data is modified, keep the required attribution and share-alike terms.

## Status

This is an early personal prototype. Scheduled notifications, larger vocabulary coverage, and production App Store setup are still in progress.
