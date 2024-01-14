import 'package:philiprehberger_retry/philiprehberger_retry.dart';

Future<String> unreliableFetch() async {
  // Simulate an unreliable operation
  return 'data';
}

Future<void> main() async {
  // Basic retry with defaults (3 attempts, exponential backoff)
  final result = await retry(() => unreliableFetch());
  print('Result: $result');

  // Custom retry configuration
  final customResult = await retry(
    () => unreliableFetch(),
    maxAttempts: 5,
    delay: const Duration(milliseconds: 500),
    backoffMultiplier: 1.5,
    jitter: true,
    timeout: const Duration(seconds: 10),
  );
  print('Custom result: $customResult');

  // Retry only on specific exceptions
  final filtered = await retry(
    () => unreliableFetch(),
    retryIf: (e) => e is FormatException,
  );
  print('Filtered result: $filtered');

  // Circuit breaker usage
  final breaker = CircuitBreaker(
    failureThreshold: 3,
    resetTimeout: const Duration(seconds: 30),
  );

  try {
    final breakerResult = await breaker.execute(() => unreliableFetch());
    print('Breaker result: $breakerResult');
  } on CircuitBreakerOpenException {
    print('Circuit is open, skipping call');
  }

  // Check circuit state
  print('Circuit state: ${breaker.state}');

  // Reset the circuit breaker
  breaker.reset();
  print('After reset: ${breaker.state}');
}
