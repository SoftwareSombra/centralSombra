import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String sender;
  final bool isCurrentUser;

  const MessageBubble(
      {super.key,
      required this.message,
      required this.sender,
      required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.red : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15.0),
                topRight: const Radius.circular(15.0),
                bottomLeft: isCurrentUser
                    ? const Radius.circular(15.0)
                    : const Radius.circular(0.0),
                bottomRight: isCurrentUser
                    ? const Radius.circular(0.0)
                    : const Radius.circular(15.0),
              ),
            ),
            child: SelectableText.rich(
              TextSpan(
                children: _linkify(message, context, isCurrentUser),
                style: TextStyle(
                    color: isCurrentUser ? Colors.white : Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
  List<TextSpan> _linkify(
      String text, BuildContext context, bool isCurrentUser) {
    final RegExp linkRegExp = RegExp(r'\b(https?://\S+)\b');
    final Iterable<Match> matches = linkRegExp.allMatches(text);

    if (matches.isEmpty) return [TextSpan(text: text)];

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(
              color: isCurrentUser ? Colors.white : Colors.blue,
              decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final url = match.group(0);
              if (await canLaunchUrl(Uri.parse(url!))) {
                if (context.mounted) {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => Widget(link: url),
                  //   ),
                  // );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Não foi possível abrir o link'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
        ),
      );
      lastMatchEnd = match.end;
    }

    spans.add(TextSpan(text: text.substring(lastMatchEnd)));

    return spans;
  }
}
