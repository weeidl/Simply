// Dart imports:
import 'dart:async';

class UpdateMessageStream {
  static final StreamController<String> _controller =
      StreamController.broadcast();

  static StreamController<String> get controller => _controller;

  static Stream<String> get stream => _controller.stream;
}
