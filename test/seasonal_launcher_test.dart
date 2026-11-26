import 'package:flutter_test/flutter_test.dart';
import 'package:neo_parlour_owner/core/data/services/app_icon_service.dart';

void main() {
  group('AppIconService Seasonal Schedule Tests', () {
    test('Diwali Theme: Nov 6 to Nov 21', () {
      expect(AppIconService.getScheduledTheme(DateTime(2026, 11, 6)), 'diwali');
      expect(AppIconService.getScheduledTheme(DateTime(2026, 11, 15)), 'diwali');
      expect(AppIconService.getScheduledTheme(DateTime(2026, 11, 21)), 'diwali');
    });

    test('Classic Revert: Nov 22 to Dec 17', () {
      expect(AppIconService.getScheduledTheme(DateTime(2026, 11, 22)), 'default');
      expect(AppIconService.getScheduledTheme(DateTime(2026, 11, 30)), 'default');
      expect(AppIconService.getScheduledTheme(DateTime(2026, 12, 1)), 'default');
      expect(AppIconService.getScheduledTheme(DateTime(2026, 12, 17)), 'default');
    });

    test('Christmas Theme: Dec 18 to Dec 27', () {
      expect(AppIconService.getScheduledTheme(DateTime(2026, 12, 18)), 'christmas');
      expect(AppIconService.getScheduledTheme(DateTime(2026, 12, 25)), 'christmas');
      expect(AppIconService.getScheduledTheme(DateTime(2026, 12, 27)), 'christmas');
    });

    test('New Year Theme: Dec 28 to Jan 6', () {
      expect(AppIconService.getScheduledTheme(DateTime(2026, 12, 28)), 'newyear');
      expect(AppIconService.getScheduledTheme(DateTime(2026, 12, 31)), 'newyear');
      expect(AppIconService.getScheduledTheme(DateTime(2027, 1, 1)), 'newyear');
      expect(AppIconService.getScheduledTheme(DateTime(2027, 1, 6)), 'newyear');
    });

    test('Classic Revert: Jan 7 onwards', () {
      expect(AppIconService.getScheduledTheme(DateTime(2027, 1, 7)), 'default');
      expect(AppIconService.getScheduledTheme(DateTime(2027, 2, 14)), 'default');
      expect(AppIconService.getScheduledTheme(DateTime(2027, 6, 1)), 'default');
      expect(AppIconService.getScheduledTheme(DateTime(2027, 10, 31)), 'default');
    });
  });
}
