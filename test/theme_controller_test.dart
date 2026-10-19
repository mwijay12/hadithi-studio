/// Majaribio ya [ThemeController] — kibadilishi cha muonekano.
///
/// ## Kwa nini haya ni muhimu
///
/// Mtumiaji aliripoti kwamba **hakukuwa na mahali pa kubadilisha muonekano**:
/// `MaterialApp` ilikuwa na `themeMode: ThemeMode.system` iliyowekwa moja kwa
/// moja. Majaribio haya huthibitisha mambo mawili:
///
/// 1. chaguo linabadilisha `ThemeMode` inayotumwa kwenye `MaterialApp`;
/// 2. chaguo **linadumu** — hakirudi kwenye default kila kufungua app.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/services/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('chaguo la muonekano', () {
    test('default ni Nuru — sivyo kufuata simu', () async {
      final ThemeController controller = ThemeController();
      await controller.restore();
      // Nuru ni default kwa makusudi: kurasa ambazo bado hazijabadilishwa
      // zinaonekana vizuri kwenye nuru. `system` ingewapa watumiaji wa
      // dark-mode mandhari nusu iliyobadilishwa.
      expect(controller.selection, AppThemeMode.light);
      expect(controller.themeMode, ThemeMode.light);
    });

    test('kuchagua Giza hubadilisha ThemeMode papo hapo', () async {
      final ThemeController controller = ThemeController();
      await controller.restore();
      await controller.use(AppThemeMode.dark);
      expect(controller.themeMode, ThemeMode.dark);
    });

    test('chaguo linadumu kwa mfano MPYA', () async {
      final ThemeController first = ThemeController();
      await first.restore();
      await first.use(AppThemeMode.dark);

      final ThemeController reopened = ThemeController();
      await reopened.restore();
      expect(
        reopened.selection,
        AppThemeMode.dark,
        reason: 'muonekano ulirudi default — chaguo halikuhifadhiwa',
      );
    });

    test('Mfumo unarudisha ThemeMode.system', () async {
      final ThemeController controller = ThemeController();
      await controller.restore();
      await controller.use(AppThemeMode.system);
      expect(controller.themeMode, ThemeMode.system);

      final ThemeController reopened = ThemeController();
      await reopened.restore();
      expect(reopened.selection, AppThemeMode.system);
    });

    test('thamani isiyojulikana kwenye hifadhi hurudi Nuru', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        ThemeController.prefsKey: 'haijulikani',
      });
      final ThemeController controller = ThemeController();
      await controller.restore();
      expect(controller.selection, AppThemeMode.light);
    });

    test('kuchagua chaguo lile lile hakuna taarifa ya bure', () async {
      final ThemeController controller = ThemeController();
      await controller.restore();
      int notified = 0;
      controller.addListener(() => notified++);
      await controller.use(AppThemeMode.light);
      expect(notified, 0);
      await controller.use(AppThemeMode.dark);
      expect(notified, 1);
    });
  });

  group('majina ya UI', () {
    test('kila chaguo lina jina la Kiswahili na Kiingereza', () {
      for (final AppThemeMode mode in AppThemeMode.values) {
        expect(mode.labelSw.trim(), isNotEmpty);
        expect(mode.labelEn.trim(), isNotEmpty);
      }
    });
  });
}
