import 'package:philiprehberger_retry/retry.dart';
import 'package:test/test.dart';

void main() {
  group('CircuitBreaker', () {
    test('closed state allows calls through', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 3,
        resetTimeout: const Duration(seconds: 30),
      );

      final result = await breaker.execute(() async => 'success');
      expect(result, equals('success'));
      expect(breaker.state, equals(CircuitState.closed));
    });

    test('opens after reaching failure threshold', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 2,
        resetTimeout: const Duration(seconds: 30),
      );

      for (var i = 0; i < 2; i++) {
        try {
          await breaker.execute(() async => throw Exception('fail'));
        } catch (_) {}
      }

      expect(breaker.state, equals(CircuitState.open));
    });

    test('open state throws CircuitBreakerOpenException', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 1,
        resetTimeout: const Duration(seconds: 30),
      );

      try {
        await breaker.execute(() async => throw Exception('fail'));
      } catch (_) {}

      expect(breaker.state, equals(CircuitState.open));
      expect(
        () => breaker.execute(() async => 'success'),
        throwsA(isA<CircuitBreakerOpenException>()),
      );
    });

    test('transitions to half-open after reset timeout', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 1,
        resetTimeout: const Duration(milliseconds: 50),
      );

      try {
        await breaker.execute(() async => throw Exception('fail'));
      } catch (_) {}

      expect(breaker.state, equals(CircuitState.open));

      // Wait for reset timeout
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(breaker.state, equals(CircuitState.halfOpen));
    });

    test('success in half-open state closes the circuit', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 1,
        resetTimeout: const Duration(milliseconds: 50),
      );

      try {
        await breaker.execute(() async => throw Exception('fail'));
      } catch (_) {}

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(breaker.state, equals(CircuitState.halfOpen));

      final result = await breaker.execute(() async => 'recovered');
      expect(result, equals('recovered'));
      expect(breaker.state, equals(CircuitState.closed));
    });

    test('reset() restores closed state', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 1,
        resetTimeout: const Duration(seconds: 30),
      );

      try {
        await breaker.execute(() async => throw Exception('fail'));
      } catch (_) {}

      expect(breaker.state, equals(CircuitState.open));

      breaker.reset();
      expect(breaker.state, equals(CircuitState.closed));

      final result = await breaker.execute(() async => 'success');
      expect(result, equals('success'));
    });
  });
}
