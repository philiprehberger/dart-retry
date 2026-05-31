# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-05-30

### Added
- `CircuitBreaker.onStateChange` callback invoked on every transition between `closed`, `open`, and `halfOpen` — useful for metrics, logging, and alerting

### Changed
- Revert minimum Dart SDK from 3.8 back to 3.6 (no 3.8-only features are used and 3.6 is the package guide standard)

## [0.4.0] - 2026-04-06

### Changed
- Upgrade `lints` from 5.x to 5.x–6.x range
- Bump minimum Dart SDK from 3.6 to 3.8

## [0.3.0] - 2026-04-05

### Added
- `retryWithBackoff()` convenience function with sensible exponential backoff defaults (maxAttempts: 5, delay: 1s, backoffMultiplier: 2.0, jitter: true)

## [0.2.0] - 2026-04-04

### Added
- `onRetry` callback parameter for observing retry attempts with error and delay info

## [0.1.0] - 2026-04-03

### Added
- Initial release
- Configurable retry with exponential backoff and jitter
- Circuit breaker with failure threshold and automatic reset
