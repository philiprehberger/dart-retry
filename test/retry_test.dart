import 'package:philiprehberger_retry/retry.dart';
import 'package:test/test.dart';

void main() {
  group('retry', () {
    test('succeeds on first try without retrying', () async {
      var callCount = 0;
      final result = await retry(
        () async {
          callCount++;
          return 'success';
        },
        jitter: false,
      );

      expect(result, equals('success'));
      expect(callCount, equals(1));
    });

    test('retries on failure and eventually succeeds', () async {
      var callCount = 0;
      final result = await retry(
        () async {
          callCount++;
          if (callCount < 3) throw Exception('fail');
          return 'success';
        },
        maxAttempts: 5,
        delay: const Duration(milliseconds: 1),
        jitter: false,
      );

      expect(result, equals('success'));
      expect(callCount, equals(3));
    });

    test('respects maxAttempts and throws after exhaustion', () async {
      var callCount = 0;
      expect(
        () => retry(
          () async {
            callCount++;
            throw Exception('always fails');
          },
          maxAttempts: 3,
          delay: const Duration(milliseconds: 1),
          jitter: false,
        ),
        throwsException,
      );
    });

    test('retryIf filters which exceptions to retry', () async {
      var callCount = 0;
      expect(
        () => retry(
          () async {
            callCount++;
            throw const FormatException('bad format');
          },
          maxAttempts: 5,
          delay: const Duration(milliseconds: 1),
          jitter: false,
          retryIf: (e) => e is! FormatException,
        ),
        throwsFormatException,
      );

      // Should not retry because retryIf returns false for FormatException
      expect(callCount, equals(1));
    });

    test('timeout causes TimeoutException', () async {
      expect(
        () => retry(
          () async {
            await Future<void>.delayed(const Duration(seconds: 5));
            return 'never';
          },
          maxAttempts: 1,
          delay: const Duration(milliseconds: 1),
          jitter: false,
          timeout: const Duration(milliseconds: 50),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
