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
  void Function(int attempt, Object error, Duration delay)? onRetry,
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

      if (onRetry != null) {
        onRetry(attempt, e, waitTime);
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

/// Retry with pre-configured exponential backoff defaults.
///
/// Uses sensible defaults: 5 attempts, 1 second initial delay,
/// 2x backoff multiplier, and jitter enabled.
///
/// ```dart
/// final result = await retryWithBackoff(() => fetchData());
/// ```
Future<T> retryWithBackoff<T>(
  Future<T> Function() fn, {
  int maxAttempts = 5,
  void Function(int attempt, Object error, Duration delay)? onRetry,
}) async {
  return retry(
    fn,
    maxAttempts: maxAttempts,
    delay: const Duration(seconds: 1),
    backoffMultiplier: 2.0,
    jitter: true,
    onRetry: onRetry,
  );
}
