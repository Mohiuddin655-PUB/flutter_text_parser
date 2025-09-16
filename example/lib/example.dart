import 'package:flutter/material.dart';
import 'package:flutter_text_parser/flutter_text_parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Text Parser Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ParserDemo(),
    );
  }
}

class ParserDemo extends StatelessWidget {
  const ParserDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Example string with nested tags
    String exampleText =
        "<b><i>Flutter</i></b> is <color:red>awesome</color> and <u>fun</u>!";

    // Parse the string into TextParts
    List<TextPart> parsedParts = exampleText.parsedSpanTexts;

    return Scaffold(
      appBar: AppBar(title: const Text('Text Parser Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RichText(
          text: TextSpan(
            children: parsedParts.map((part) {
              if (part is NormalText) {
                return TextSpan(
                  text: part.text,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                );
              } else if (part is SpannedText) {
                TextStyle style = const TextStyle(fontSize: 18);

                for (var tag in part.tags) {
                  switch (tag.tag) {
                    case 'b':
                    case 'bold':
                      style = style.merge(
                        const TextStyle(fontWeight: FontWeight.bold),
                      );
                      break;
                    case 'i':
                    case 'italic':
                      style = style.merge(
                        const TextStyle(fontStyle: FontStyle.italic),
                      );
                      break;
                    case 'u':
                    case 'underline':
                      style = style.merge(
                        const TextStyle(decoration: TextDecoration.underline),
                      );
                      break;
                    case 'l':
                    case 'lineThrough':
                      style = style.merge(
                        const TextStyle(decoration: TextDecoration.lineThrough),
                      );
                      break;
                    case 'color':
                      if (tag.attr != null) {
                        style = style.merge(
                          TextStyle(color: _parseColor(tag.attr!)),
                        );
                      }
                      break;
                  }
                }

                return TextSpan(text: part.text, style: style);
              }
              return const TextSpan(text: '');
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Simple helper to convert color strings like "red" or "#FF0000"
  Color _parseColor(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      default:
        // Parse hex color like #RRGGBB
        if (colorString.startsWith('#') && colorString.length == 7) {
          return Color(
            int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
          );
        }
        return Colors.black;
    }
  }
}
