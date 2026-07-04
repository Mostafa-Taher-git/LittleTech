import 'package:flutter_test/flutter_test.dart';
import 'package:littletech/src/core/services/rule_engine.dart';

void main() {
  group('RuleEngine Tests', () {
    test('should return solution for no display', () {
      final result = RuleEngine.solve('no display');
      expect(result, isNotNull);
      expect(result!.problem.toLowerCase(), contains('no display'));
    });

    test('should return solution for slow internet', () {
      final result = RuleEngine.solve('slow internet');
      expect(result, isNotNull);
      expect(result!.problem.toLowerCase(), contains('slow internet'));
    });

    test('should return null for unknown problem', () {
      final result = RuleEngine.solve('unknown issue that is not in rules');
      expect(result, isNull);
    });

    test('exact match returns correct category (not General)', () {
      final result = RuleEngine.solve('high cpu usage');
      expect(result, isNotNull);
      expect(result!.category, 'Core Components');
    });

    test('alias match returns correct category', () {
      final result = RuleEngine.solve('pcie slot not working');
      expect(result, isNotNull);
      expect(result!.category, 'Core Components');
    });

    test('substring match returns correct category', () {
      final result = RuleEngine.solve('slow internet connection');
      expect(result, isNotNull);
      expect(result!.category, 'Internet');
    });

    test('keyword fallback returns correct category', () {
      final result = RuleEngine.solve('monitor display screen flickering');
      expect(result, isNotNull);
      expect(result!.category, 'Display');
    });
  });
}
