# philiprehberger_retry

[![Tests](https://github.com/philiprehberger/dart-retry/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/dart-retry/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/philiprehberger_retry.svg)](https://pub.dev/packages/philiprehberger_retry)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/dart-retry)](https://github.com/philiprehberger/dart-retry/commits/main)

![philiprehberger_retry](https://raw.githubusercontent.com/philiprehberger/dart-retry/main/package-card.webp)

Configurable retry with exponential backoff, jitter, and circuit breaker

## Requirements

- Dart >= 3.6

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  philiprehberger_retry: ^0.5.0
```

Then run:

```bash
dart pub get
```

## Usage

```dart
import 'package:philiprehberger_retry/philiprehberger_retry.dart';

final result = await retry(() => fetchData());
```

### Retry with Custom Options

```dart
final result = await retry(
  () => fetchData(),
  maxAttempts: 5,
  delay: Duration(milliseconds: 500),
  backoffMultiplier: 1.5,
  jitter: true,
  timeout: Duration(seconds: 10),
);
```

### Retry with Callback

```dart
await retry(
  () => fetchData(),
  onRetry: (attempt, error, delay) {
    print('Attempt $attempt failed: $error. Retrying in $delay...');
  },
);
```

### Retry with Backoff (Convenience)

```dart
final result = await retryWithBackoff(() => fetchData());
```

Pre-configured with 5 attempts, 1 second initial delay, 2x backoff multiplier, and jitter enabled.

### Retry Only Specific Exceptions

```dart
final result = await retry(
  () => fetchData(),
  retryIf: (e) => e is SocketException,
);
```

### Circuit Breaker

```dart
final breaker = CircuitBreaker(
  failureThreshold: 3,
  resetTimeout: Duration(seconds: 30),
);

try {
  final result = await breaker.execute(() => fetchData());
} on CircuitBreakerOpenException {
  print('Circuit is open, skipping call');
}
```

### Observing State Changes

```dart
final breaker = CircuitBreaker(
  failureThreshold: 3,
  resetTimeout: Duration(seconds: 30),
  onStateChange: (from, to) {
    metrics.recordTransition(from, to);
    log('circuit: $from -> $to');
  },
);
```

## API

| Symbol | Description |
|--------|-------------|
| `retry()` | Retry an async operation with configurable backoff |
| `retryWithBackoff()` | Convenience retry with exponential backoff defaults |
| `onRetry` | Optional callback invoked before each retry with attempt number, error, and delay |
| `CircuitBreaker` | Prevents repeated calls to a failing service |
| `CircuitBreaker.execute()` | Execute a function through the circuit breaker |
| `CircuitBreaker.state` | Current circuit state (closed, open, halfOpen) |
| `CircuitBreaker.onStateChange` | Optional callback fired on state transitions |
| `CircuitBreaker.reset()` | Reset the circuit breaker to closed state |
| `CircuitState` | Enum: `closed`, `open`, `halfOpen` |
| `CircuitBreakerOpenException` | Thrown when executing through an open circuit |

## Development

```bash
dart pub get
dart analyze --fatal-infos
dart test
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/dart-retry)

🐛 [Report issues](https://github.com/philiprehberger/dart-retry/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/dart-retry/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
