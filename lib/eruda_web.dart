import 'dart:html' as html;

void injectEruda() {
  final script = html.ScriptElement()
    ..src = 'https://cdn.jsdelivr.net/npm/eruda'
    ..type = 'text/javascript';

  script.onLoad.listen((_) {
    html.querySelector('body')?.children.add(
          html.ScriptElement()..innerHtml = 'eruda.init();',
        );
  });

  html.document.head?.children.add(script);
}
