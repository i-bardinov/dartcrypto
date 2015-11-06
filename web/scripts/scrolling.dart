library scrolling;

import 'dart:async' as async show Completer, Future;
import 'dart:html' as html show Element, window, document;
import 'dart:math' as math show max;

double fullOffsetTop(html.Element element) => element.getBoundingClientRect().top +
    html.window.pageYOffset -
    html.document.documentElement.clientTop;

Duration getDuration(html.Element targetElement, num speed) {
  var distance = (html.window.pageYOffset - fullOffsetTop(targetElement)).abs();
  return new Duration(milliseconds: distance ~/ speed);
}

async.Future scrollTo(html.Element el, Duration duration, TimingFunction tf) {
  var isCompleted = false,
      isInterrupted = false,
      completer = new async.Completer(),
      startPos = html.window.pageYOffset,
      targetPos = fullOffsetTop(el),
      overScroll =
      math.max(targetPos + html.window.innerHeight - html.document.body.scrollHeight, 0),
      startTime = null,
      direction = (targetPos - startPos).sign;

  targetPos -= overScroll;

  var totalDistance = (targetPos - startPos).abs();

  //make text unselectable and disable events
  //like onMouseOver for better performance during the scroll.
  String disable = "-webkit-user-select: none;"
      "-moz-user-select: none;"
      "-ms-user-select: none;"
      "-o-user-select: none;"
      "user-select: none;"
      "pointer-events: none;";

  String oldBodyStyle = html.document.body.getAttribute("style") != null
      ? html.document.body.getAttribute("style")
      : "";

  //return control to the user if he/she tries to interact with the page.
  html.window.onMouseWheel.first.then((_) => isInterrupted = isCompleted = true);
  html.window.onKeyDown.first.then((_) => isInterrupted = isCompleted = true);

  html.document.body.setAttribute("style", disable + oldBodyStyle);

  iter() {
    html.window.animationFrame.then((_) {
      if (startTime == null) startTime = html.window.performance.now();
      var deltaTime = html.window.performance.now() - startTime,
          progress = deltaTime / duration.inMilliseconds,
          precision = (1000 / 60 / duration.inMilliseconds) / 4,
          dist = totalDistance * tf(progress, precision);
      var curPos = startPos + dist * direction;

      if (progress >= 1.0) isCompleted = true;

      if (!isCompleted) {
        html.window.scrollTo(0, curPos.toInt());
        iter();
      } else {
        html.document.body.setAttribute("style",
            html.document.body.getAttribute("style").replaceFirst(disable, ""));
        isInterrupted
            ? completer.completeError("Interrupted by the user")
            : completer.complete("completed");
      }
    });
  }
  iter();
  return completer.future;
}

typedef num TimingFunction(num time, num precision);

abstract class TimingFunctions {
  static TimingFunction easeInOut = makeCubicBezier(0.42, 0, 0.58, 1);
  static TimingFunction easeOut = makeCubicBezier(0.25, 0.1, 0.25, 1);
}

TimingFunction makeCubicBezier(x1, y1, x2, y2) {
  var curveX = (t) {
    var v = 1 - t;
    return 3 * v * v * t * x1 + 3 * v * t * t * x2 + t * t * t;
  };

  var curveY = (t) {
    var v = 1 - t;
    return 3 * v * v * t * y1 + 3 * v * t * t * y2 + t * t * t;
  };

  var derivativeCurveX = (t) {
    var v = 1 - t;
    return 3 * (2 * (t - 1) * t + v * v) * x1 +
        3 * (-t * t * t + 2 * v * t) * x2;
  };
  return (t, precision) {
    var x = t, t0, t1, t2, x2, d2, i;
    for (i = 0; i < 8; i++) {
      t2 = x;
      x2 = curveX(t2) - x;
      if (x2.abs() < precision) return curveY(t2);
      d2 = derivativeCurveX(t2);
      if (d2.abs() < 1e-6) break;
      t2 = t2 - x2 / d2;
    }
    t0 = 0;
    t1 = 1;
    t2 = x;

    if (t2 < t0) return curveY(t0);
    if (t2 > t1) return curveY(t1);
    while (t0 < t1) {
      x2 = curveX(t2);
      if ((x2 - x).abs() < precision) return curveY(t2);
      if (x > x2) {
        t0 = t2;
      } else {
        t1 = t2;
      }
      t2 = (t1 - t0) * .5 + t0;
    }
    return curveY(t2);
  };
}
