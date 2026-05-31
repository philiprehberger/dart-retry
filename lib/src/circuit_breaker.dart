/// Circuit breaker states.
enum CircuitState { closed, open, halfOpen }

/// A circuit breaker that prevents repeated calls to a failing service.
///
/// ```dart
/// final breaker = CircuitBreaker(
///   failureThreshold: 3,
///   resetTimeout: Duration(seconds: 30),
///   onStateChange: (from, to) => log('breaker: $from -> $to'),
/// );
/// final result = await breaker.execute(() => fetchData());
/// ```
class CircuitBreaker {
  /// Number of failures before the circuit opens.
  final int failureThreshold;

  /// How long to wait before trying again (half-open state).
  final Duration resetTimeout;

  /// Optional callback fired whenever the circuit transitions between
  /// states (closed, open, halfOpen).
  ///
  /// The `open → halfOpen` transition is detected lazily on the next read
  /// of [state] or call to [execute].
  final void Function(CircuitState from, CircuitState to)? onStateChange;

  int _failureCount = 0;
  CircuitState _state = CircuitState.closed;
  CircuitState _lastObservedState = CircuitState.closed;
  DateTime? _lastFailure;

  /// Create a circuit breaker.
  CircuitBreaker({
    required this.failureThreshold,
    required this.resetTimeout,
    this.onStateChange,
  });

  /// The current circuit state.
  CircuitState get state {
    final current = _computeState();
    _notifyIfChanged(current);
    return current;
  }

  CircuitState _computeState() {
    if (_state == CircuitState.open && _lastFailure != null) {
      if (DateTime.now().difference(_lastFailure!) >= resetTimeout) {
        return CircuitState.halfOpen;
      }
    }
    return _state;
  }

  void _notifyIfChanged(CircuitState newState) {
    if (newState != _lastObservedState) {
      final from = _lastObservedState;
      _lastObservedState = newState;
      onStateChange?.call(from, newState);
    }
  }

  /// Execute [fn] through the circuit breaker.
  ///
  /// Throws [CircuitBreakerOpenException] if the circuit is open.
  Future<T> execute<T>(Future<T> Function() fn) async {
    final currentState = state;

    if (currentState == CircuitState.open) {
      throw CircuitBreakerOpenException();
    }

    try {
      final result = await fn();
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure();
      rethrow;
    }
  }

  void _onSuccess() {
    _failureCount = 0;
    _state = CircuitState.closed;
    _notifyIfChanged(CircuitState.closed);
  }

  void _onFailure() {
    _failureCount++;
    _lastFailure = DateTime.now();
    if (_failureCount >= failureThreshold) {
      _state = CircuitState.open;
      _notifyIfChanged(CircuitState.open);
    }
  }

  /// Reset the circuit breaker to closed state.
  void reset() {
    _failureCount = 0;
    _state = CircuitState.closed;
    _lastFailure = null;
    _notifyIfChanged(CircuitState.closed);
  }
}

/// Thrown when attempting to execute through an open circuit.
class CircuitBreakerOpenException implements Exception {
  @override
  String toString() => 'CircuitBreakerOpenException: Circuit is open';
}
