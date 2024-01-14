import 'dart:math';

/// Retry an async operation with configurable backoff.
///
/// ```dart
/// final result = await retry(() => fetchData(), maxAttempts: 3);
/// ```
Future<T> retry<T>(
  Future<T> Function() fn, {
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 1),
  double backoffMultiplier = 2.0,
  bool jitter = true,
  bool Function(Exception)? retryIf,
  Duration? timeout,
}) async {
  final random = Random();
  var currentDelay = delay;

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      if (timeout != null) {
        return await fn().timeout(timeout);
      }
      return await fn();
    } on Exception catch (e) {
      if (attempt == maxAttempts) rethrow;
      if (retryIf != null && !retryIf(e)) rethrow;

      var waitTime = currentDelay;
      if (jitter) {
        final jitterMs = random.nextInt(currentDelay.inMilliseconds ~/ 2 + 1);
        waitTime = currentDelay + Duration(milliseconds: jitterMs);
      }

      await Future<void>.delayed(waitTime);
      currentDelay = Duration(
        milliseconds: (currentDelay.inMilliseconds * backoffMultiplier).round(),
      );
    }
  }

  // Should not reach here
  return fn();
}
