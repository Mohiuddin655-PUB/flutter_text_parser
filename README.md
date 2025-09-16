# flutter_text_parser

`flutter_text_parser` is a Dart library that allows you to parse strings with custom HTML-like tags
and convert them into styled spanned text for Flutter. It supports nested tags, inline formatting,
colors, and more.

---

## Features

- Parse strings with custom tags like `<b>`, `<i>`, `<u>`, `<color:red>`, etc.
- Supports nested tags.
- Returns a list of `TextPart` containing `NormalText` and `SpannedText`.
- Easy to convert to styled Flutter widgets.

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_text_parser:
    git:
      url: https://github.com/yourusername/flutter_text_parser.git
```

Then run

```base
flutter pub get
```

---

## Usage

```dart
import 'package:flutter_text_parser/flutter_text_parser.dart';

void main() {
  String text = "<b><i>Flutter</i></b> is <color:red>awesome</color>!";
  List<TextPart> parsed = text.parsedSpanTexts;

  for (var part in parsed) {
    print(part);
    // Output: SpannedText(text: Flutter, tags: [b, i])
    //         NormalText( is )
    //         SpannedText(text: awesome, tags: [color:red])
  }
}
```

---

## TextPart Types

- NormalText: Regular text without styling.
- SpannedText: Text with applied tags.
- SpannedTag: Represents a tag with an optional attribute (like color).

---

## Supported Tags

- Bold: <b> or <bold>
- Italic: <i> or <italic>
- Underline: <u> or <underline>
- LineThrough: <l> or <lineThrough>
- Overline: <o> or <overline>
- Color: <color:red> or <color:#FF0000>

You can also define custom tags as needed.

---

## Extension Method

You can directly parse strings using the extension:

```dart

String text = "<b>Hello</b> world!";
List<TextPart> parsed = text.parsedSpanTexts;
```

---

## Example Output

Input:

```text
<b><i>Flutter</i></b> is <color:red>awesome</color>
```

Parsed Output:

```text
SpannedText(text: Flutter, tags: [b, i])
NormalText( is )
SpannedText(text: awesome, tags: [color:red])
```