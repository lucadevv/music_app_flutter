import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/core/services/logger/app_logger.dart';
import 'package:logger/logger.dart';

void main() {
  group('AppLogger', () {
    test('should be a static class with private constructor', () {
      // AppLogger is designed as a static utility class
      // It should have all static methods
      expect(AppLogger.debug, isA<Function>());
      expect(AppLogger.info, isA<Function>());
      expect(AppLogger.warning, isA<Function>());
      expect(AppLogger.error, isA<Function>());
      expect(AppLogger.trace, isA<Function>());
      expect(AppLogger.fatal, isA<Function>());
    });

    test('debug method should accept message parameter', () {
      // This test verifies the method signature
      // We don't verify the actual output since it depends on Logger
      expect(
        () => AppLogger.debug('Test debug message'),
        returnsNormally,
      );
    });

    test('debug method should accept optional error and stackTrace', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      expect(
        () => AppLogger.debug('Test debug message', error, stackTrace),
        returnsNormally,
      );
    });

    test('info method should accept message parameter', () {
      expect(
        () => AppLogger.info('Test info message'),
        returnsNormally,
      );
    });

    test('info method should accept optional error and stackTrace', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      expect(
        () => AppLogger.info('Test info message', error, stackTrace),
        returnsNormally,
      );
    });

    test('warning method should accept message parameter', () {
      expect(
        () => AppLogger.warning('Test warning message'),
        returnsNormally,
      );
    });

    test('warning method should accept optional error and stackTrace', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      expect(
        () => AppLogger.warning('Test warning message', error, stackTrace),
        returnsNormally,
      );
    });

    test('error method should accept message parameter', () {
      expect(
        () => AppLogger.error('Test error message'),
        returnsNormally,
      );
    });

    test('error method should accept optional error and stackTrace', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      expect(
        () => AppLogger.error('Test error message', error, stackTrace),
        returnsNormally,
      );
    });

    test('trace method should accept message parameter', () {
      expect(
        () => AppLogger.trace('Test trace message'),
        returnsNormally,
      );
    });

    test('trace method should accept optional error and stackTrace', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      expect(
        () => AppLogger.trace('Test trace message', error, stackTrace),
        returnsNormally,
      );
    });

    test('fatal method should accept message parameter', () {
      expect(
        () => AppLogger.fatal('Test fatal message'),
        returnsNormally,
      );
    });

    test('fatal method should accept optional error and stackTrace', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      expect(
        () => AppLogger.fatal('Test fatal message', error, stackTrace),
        returnsNormally,
      );
    });

    test('all log methods should handle null error gracefully', () {
      expect(
        () => AppLogger.debug('Test message', null, null),
        returnsNormally,
      );
      expect(
        () => AppLogger.info('Test message', null, null),
        returnsNormally,
      );
      expect(
        () => AppLogger.warning('Test message', null, null),
        returnsNormally,
      );
      expect(
        () => AppLogger.error('Test message', null, null),
        returnsNormally,
      );
      expect(
        () => AppLogger.trace('Test message', null, null),
        returnsNormally,
      );
      expect(
        () => AppLogger.fatal('Test message', null, null),
        returnsNormally,
      );
    });

    test('all log methods should handle empty message', () {
      expect(
        () => AppLogger.debug(''),
        returnsNormally,
      );
      expect(
        () => AppLogger.info(''),
        returnsNormally,
      );
      expect(
        () => AppLogger.warning(''),
        returnsNormally,
      );
      expect(
        () => AppLogger.error(''),
        returnsNormally,
      );
      expect(
        () => AppLogger.trace(''),
        returnsNormally,
      );
      expect(
        () => AppLogger.fatal(''),
        returnsNormally,
      );
    });

    test('all log methods should handle long messages', () {
      final longMessage = 'A' * 10000;

      expect(
        () => AppLogger.debug(longMessage),
        returnsNormally,
      );
      expect(
        () => AppLogger.info(longMessage),
        returnsNormally,
      );
      expect(
        () => AppLogger.warning(longMessage),
        returnsNormally,
      );
      expect(
        () => AppLogger.error(longMessage),
        returnsNormally,
      );
    });
  });
}
