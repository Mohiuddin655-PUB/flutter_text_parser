import 'package:flutter/material.dart';

import 'flutter_text_parser.dart';

typedef TextParserScaler = double Function(double value);
typedef TextParserBuilder =
    Widget Function(BuildContext context, List<TextSpan> spans);

class SpannableText extends StatelessWidget {
  final String data;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextStyle? style;
  final TextDirection? textDirection;
  final TextParserScaler? scaler;
  final TextParserBuilder? builder;

  const SpannableText(
    this.data, {
    super.key,
    this.maxLines,
    this.scaler,
    this.style,
    this.textAlign,
    this.textDirection,
    this.builder,
  });

  static T? _enum<T extends Enum>(Object? source, Iterable<T> enums) {
    try {
      return enums.firstWhere((e) {
        if (e.index == source) return true;
        if (e.name == source) return true;
        if (e.toString() == source) return true;
        return false;
      });
    } catch (_) {
      return null;
    }
  }

  static FontWeight? _fontWeight(Object? source) {
    try {
      return FontWeight.values.firstWhere((e) {
        if (e.index == source) return true;
        if (e.value == source) return true;
        if (e.toString() == source) return true;
        return false;
      });
    } catch (_) {
      return null;
    }
  }

  static double? _double(String source) => double.tryParse(source);

  static String? _string(Object? source) {
    return source is String && source.isNotEmpty ? source : null;
  }

  static Color? _color(String source) {
    source = source.toLowerCase();
    if (source.startsWith('#') || source.startsWith("0x")) {
      source = source.replaceAll('#', '').replaceAll('0x', '');
      if (source.length == 6) source = "ff$source";
      if (source.length != 8) return null;
      final code = int.tryParse('0x$source');
      if (code == null) return null;
      return Color(code);
    }
    return {
      "amber": Colors.amber,
      "black": Colors.black,
      "blue": Colors.blue,
      "brown": Colors.brown,
      "cyan": Colors.cyan,
      "grey": Colors.grey,
      "green": Colors.green,
      "indigo": Colors.indigo,
      "lime": Colors.lime,
      "orange": Colors.orange,
      "pink": Colors.pink,
      "purple": Colors.purple,
      "red": Colors.red,
      "teal": Colors.teal,
      "transparent": Colors.transparent,
      "none": Colors.transparent,
      "white": Colors.white,
      "yellow": Colors.yellow,
    }[source];
  }

  static TextDecorationStyle? _decorationStyle(Object? source) {
    return _enum(source, TextDecorationStyle.values);
  }

  static Locale? _locale(Object? source) {
    if (source is! String) return null;
    final parts = source.replaceAll("-", "_").split("_");
    return parts.length == 1
        ? Locale(parts.first)
        : parts.length == 2
        ? Locale(parts.first, parts.last)
        : null;
  }

  static TextStyle spanStyle(SpannedTag tag, [TextStyle? style]) {
    style ??= TextStyle();
    TextDecoration td(TextDecoration decoration) {
      if (style?.decoration == null) return decoration;
      return TextDecoration.combine([style!.decoration!, decoration]);
    }

    switch (tag.tag) {
      case 'b':
      case 'bold':
        return style.copyWith(fontWeight: FontWeight.bold);
      case 'i':
      case 'italic':
        return style.copyWith(fontStyle: FontStyle.italic);
      case 'l':
      case 'lt':
      case 'line_through':
      case 'line-through':
        return style.copyWith(decoration: td(TextDecoration.lineThrough));
      case 'o':
      case 'overline':
        return style.copyWith(decoration: td(TextDecoration.overline));
      case 'u':
      case 'underline':
        return style.copyWith(decoration: td(TextDecoration.underline));
      case 'c':
      case 'color':
        if (tag.attr == null) return style;
        return style.copyWith(color: _color(tag.attr!));
      case 'bg':
      case 'background':
      case 'background_color':
      case 'background-color':
        if (tag.attr == null) return style;
        return style.copyWith(backgroundColor: _color(tag.attr!));
      case 'dc':
      case 'decoration_color':
      case 'decoration-color':
        if (tag.attr == null) return style;
        return style.copyWith(decorationColor: _color(tag.attr!));
      case 'ds':
      case 'decoration_style':
      case 'decoration-style':
        if (tag.attr == null) return style;
        return style.copyWith(decorationStyle: _decorationStyle(tag.attr!));
      case 'dt':
      case 'decoration_thickness':
      case 'decoration-thickness':
        if (tag.attr == null) return style;
        return style.copyWith(decorationThickness: _double(tag.attr!));
      case 'f':
      case 'ff':
      case 'family':
      case 'font_family':
      case 'font-family':
        if (tag.attr == null) return style;
        return style.copyWith(fontFamily: _string(tag.attr!));
      case 's':
      case 'fs':
      case 'font_size':
      case 'font-size':
        if (tag.attr == null) return style;
        return style.copyWith(fontSize: _double(tag.attr!));
      case 'w':
      case 'fw':
      case 'weight':
      case 'font_weight':
      case 'font-weight':
        if (tag.attr == null) return style;
        return style.copyWith(fontWeight: _fontWeight(tag.attr!));
      case 'h':
      case 'height':
        if (tag.attr == null) return style;
        return style.copyWith(height: _double(tag.attr!));
      case 'lo':
      case 'locale':
        if (tag.attr == null) return style;
        return style.copyWith(locale: _locale(tag.attr!));
      case 'ls':
      case 'letter_spacing':
      case 'letter-spacing':
        if (tag.attr == null) return style;
        return style.copyWith(letterSpacing: _double(tag.attr!));
      case 'ws':
      case 'word_spacing':
      case 'word-spacing':
        if (tag.attr == null) return style;
        return style.copyWith(wordSpacing: _double(tag.attr!));
      default:
        return style;
    }
  }

  TextStyle _style(TextStyle s, SpannedTag t) => spanStyle(t, s);

  double? _scale(double? value) {
    if (value == null) return null;
    if (scaler == null) return value;
    return scaler!(value);
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox();
    final parts = data.parsedSpanTexts;
    if (parts.isEmpty) return SizedBox();
    final spans = parts.map((part) {
      if (part is SpannedText) {
        final s = part.tags.fold(TextStyle(), _style);
        return TextSpan(
          text: part.text,
          style: s.copyWith(
            fontSize: _scale(s.fontSize!),
            decorationThickness: _scale(s.decorationThickness),
          ),
        );
      }
      return TextSpan(text: part.text, style: style);
    }).toList();
    if (builder != null) return builder!(context, spans);
    return RichText(
      text: TextSpan(children: spans, style: style),
      maxLines: maxLines,
      textAlign: textAlign ?? TextAlign.start,
      textDirection: textDirection,
    );
  }
}
