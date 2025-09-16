/// A utility class for parsing strings with custom HTML-like tags
/// and returning a list of styled text parts (`TextPart`).
class TextParser {
  const TextParser._();

  /// Parses the [source] string and returns a list of [TextPart].
  ///
  /// Automatically wraps the string with `<p>` tags if they are missing.
  /// Supports nested tags like `<b>`, `<i>`, `<color:red>`, etc.
  static List<TextPart> parse(String source) {
    if (source.isEmpty) return [];
    if (!source.startsWith("<p>")) {
      source = "<p>$source";
    }
    if (!source.endsWith("</p>")) {
      source = "$source</p>";
    }
    List<TextPart> texts = [];

    // Regex to extract everything inside <p> tags
    RegExp pTagExp = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true);

    // Regex to match <tag> or <tag:attr> ... </tag(:attr)?>
    RegExp spanTagExp = RegExp(
      r'<(\w+)(?::([^>]+))?[^>]*>(.*?)</\1[^>]*>',
      dotAll: true,
    );

    // Helper function to recursively extract nested spans
    List<TextPart> parseSpans(String text, List<SpannedTag> tags) {
      List<TextPart> texts = [];

      Iterable<RegExpMatch> spanMatches = spanTagExp.allMatches(text);
      int lastIndex = 0;

      for (var spanMatch in spanMatches) {
        String spanType = spanMatch.group(1)!; // e.g. "b" or "color"
        String? attr = spanMatch.group(2); // e.g. "red" or "#37FF89"
        String spanText = spanMatch.group(3)!;
        int spanStart = spanMatch.start;
        int spanEnd = spanMatch.end;

        // Add any normal text between last index and span start
        if (spanStart > lastIndex) {
          String normalText = text.substring(lastIndex, spanStart);
          if (normalText.isNotEmpty) {
            texts.add(NormalText(normalText));
          }
        }

        // Build new tag list
        List<SpannedTag> nestedTags = [
          ...tags,
          SpannedTag(spanType, attr: attr),
        ];

        // Parse nested spans recursively
        var nestedElements = parseSpans(spanText, nestedTags);
        if (nestedElements.isEmpty) {
          texts.add(SpannedText(spanText, nestedTags));
        } else {
          texts.addAll(nestedElements);
        }

        lastIndex = spanEnd;
      }

      // Add any remaining normal text after the last span
      if (lastIndex < text.length) {
        String remainingText = text.substring(lastIndex);
        if (remainingText.isNotEmpty) {
          if (tags.isNotEmpty) {
            texts.add(SpannedText(remainingText, tags));
          } else {
            texts.add(NormalText(remainingText));
          }
        }
      }

      return texts;
    }

    // Find the content inside <p> tags
    Iterable<RegExpMatch> pMatches = pTagExp.allMatches(source);

    for (var pMatch in pMatches) {
      String pContent = pMatch.group(1)!; // Get the inner content of <p>
      texts.addAll(parseSpans(pContent, []));
    }

    return texts;
  }
}

/// Base class for parsed text parts.
abstract class TextPart {
  final String text;

  /// Returns true if the text part is italic.
  bool get isItalic => isExists({'i', 'italic'});

  /// Returns true if the text part is bold.
  bool get isBold => isExists({'b', 'bold'});

  /// Returns true if the text part has line-through decoration.
  bool get isLineThrough => isExists({'l', 'lineThrough'});

  /// Returns true if the text part has overline decoration.
  bool get isOverline => isExists({'u', 'overline'});

  /// Returns true if the text part is underlined.
  bool get isUnderline => isExists({'u', 'underline'});

  /// Returns true if the text part contains spanned tags.
  bool get isSpannedText => this is SpannedText;

  /// Checks if the text part contains any of the given [tags].
  bool isExists(Set<String> tags) {
    final x = this;
    if (x is! SpannedText) return false;
    return x.tags.any((e) => tags.contains(e.tag));
  }

  /// Returns the first [SpannedTag] that matches one of the [tags].
  SpannedTag tag(Set<String> tags) {
    if (tags.isEmpty) return SpannedTag('');
    final x = this;
    if (x is! SpannedText) {
      return SpannedTag(tags.first);
    }
    try {
      final y = x.tags.firstWhere((e) => tags.contains(e.tag));
      return y;
    } catch (_) {
      return SpannedTag(tags.first);
    }
  }

  const TextPart(this.text);

  @override
  String toString() => '$TextPart($text)';
}

/// Represents normal unstyled text.
class NormalText extends TextPart {
  const NormalText(super.text);

  @override
  String toString() => '$NormalText($text)';
}

/// Represents a tag with an optional attribute.
class SpannedTag {
  final String tag;
  final String? attr;

  const SpannedTag(this.tag, {this.attr});

  @override
  String toString() {
    if (attr == null) return tag;
    return "$tag:$attr";
  }
}

/// Represents a piece of text with applied spanned tags.
class SpannedText extends TextPart {
  final List<SpannedTag> tags;

  const SpannedText(super.text, this.tags);

  @override
  String toString() => '$SpannedText(text: $text, tags: $tags)';
}

/// Extension on [String] to directly parse it into spanned texts.
extension TextParserExtension on String {
  /// Returns a list of [TextPart] parsed from the string.
  List<TextPart> get parsedSpanTexts => TextParser.parse(this);
}
