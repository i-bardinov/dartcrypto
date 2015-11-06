library toast;

import 'dart:html';
import 'dart:async';

Future toast(String msg, {int fadeIn: 500, int show: 3000, int fadeOut: 5000}) {
  var isCompleted = false, startTime = null, completer = new Completer();
  DivElement el = new DivElement()
    ..style.width = '200px'
    ..style.height = '40px'
    ..style.position = 'fixed'
    ..style.left = '50%'
    ..style.marginLeft = '-100px'
    ..style.top = '20px'
    ..style.backgroundColor = '#383838'
    ..style.color = '#F0F0F0'
    ..style.fontSize = '16px'
    ..style.padding = '10px'
    ..style.textAlign = 'center'
    ..style.borderRadius = '2px'
    ..style.boxShadow = '0 0 24px -1px rgba(56, 56, 56, 1)'
    ..style.opacity = '1'
    ..text = msg;
  int stage = 0;
  document.body.append(el);

  iter() {
    window.animationFrame.then((_) {
      if (startTime == null) startTime = window.performance.now();
      var deltaTime = window.performance.now() - startTime;

      switch (stage) {
        case 0:
          num progress = deltaTime / fadeIn;
          if (progress >= 1.0) isCompleted = true;

          if (!isCompleted) {
            el.style.opacity = (deltaTime / fadeIn).toString();
          } else {
            startTime = null;
            isCompleted = false;
            stage += 1;
          }
          iter();
          break;
        case 1:
          num progress = deltaTime / show;
          if (progress >= 1.0) isCompleted = true;

          if (isCompleted) {
            startTime = null;
            stage += 1;
            isCompleted = false;
          }
          iter();
          break;
        case 2:
          num progress = deltaTime / fadeOut;

          if (progress >= 1.0) isCompleted = true;

          if (!isCompleted) {
            el.style.opacity = (1 - deltaTime / fadeOut).toString();
            iter();
          } else {
            el.remove();
            completer.complete("completed");
          }
          break;
      }
    });
  }
  iter();
  return completer.future;
}
