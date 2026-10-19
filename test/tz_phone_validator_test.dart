/// Majaribio ya [TzPhoneValidator].
///
/// Kanuni ya 14 ya mradi: "M-Pesa flow must work correctly". Namba ya simu ni
/// hatua ya kwanza ya mtiririko huo, hivyo inapimwa hapa kwa namba ambazo
/// Watanzania huziandika kwa kweli — ikiwemo sifuri ya mwanzo, ambayo spec ya
/// awali ingelikataa.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/utils/tz_phone_validator.dart';
import 'package:hadithi_studio/features/payments/domain/entities/payment_provider.dart';

void main() {
  group('normalise', () {
    test('huondoa sifuri ya mwanzo (namna ya kawaida Tanzania)', () {
      expect(TzPhoneValidator.normalise('0712345678'), '712345678');
    });

    test('huondoa nafasi', () {
      expect(TzPhoneValidator.normalise('712 345 678'), '712345678');
    });

    test('huondoa kiambishi cha nchi cha +255', () {
      expect(TzPhoneValidator.normalise('+255712345678'), '712345678');
    });

    test('huondoa kiambishi 255 bila + , pamoja na nafasi', () {
      expect(TzPhoneValidator.normalise('255 712 345 678'), '712345678');
    });

    test('huondoa dashes na mabano', () {
      expect(TzPhoneValidator.normalise('(0712) 345-678'), '712345678');
    });

    test('haiondoi chochote kwenye namba tupu isiyo na maana', () {
      expect(TzPhoneValidator.normalise('255'), '255');
    });
  });

  group('isValid', () {
    test('hukubali namba halali zinazoanza na 7', () {
      expect(TzPhoneValidator.isValid('0712345678'), isTrue);
      expect(TzPhoneValidator.isValid('712345678'), isTrue);
      expect(TzPhoneValidator.isValid('+255712345678'), isTrue);
    });

    test('hukubali namba halali zinazoanza na 6', () {
      expect(TzPhoneValidator.isValid('0687654321'), isTrue);
    });

    test('hukataa namba fupi', () {
      expect(TzPhoneValidator.isValid('07123456'), isFalse);
    });

    test('hukataa namba ndefu', () {
      expect(TzPhoneValidator.isValid('07123456789'), isFalse);
    });

    test('hukataa namba inayoanza na 5', () {
      expect(TzPhoneValidator.isValid('0512345678'), isFalse);
    });

    test('hukataa maandishi tupu', () {
      expect(TzPhoneValidator.isValid(''), isFalse);
    });
  });

  group('hasError', () {
    test('hakuna kosa kwenye uwanja tupu (mtumiaji hajagusa)', () {
      expect(TzPhoneValidator.hasError(''), isFalse);
    });

    test('kuna kosa mtumiaji akiandika nusu ya namba', () {
      expect(TzPhoneValidator.hasError('0712'), isTrue);
    });

    test('hakuna kosa kwenye namba kamili', () {
      expect(TzPhoneValidator.hasError('0712345678'), isFalse);
    });
  });

  group('format', () {
    test('huweka nafasi kila tarakimu tatu', () {
      expect(TzPhoneValidator.format('0712345678'), '712 345 678');
    });

    test('hurudisha maandishi kama yalivyo kama hayajakamilika', () {
      expect(TzPhoneValidator.format('0712'), '0712');
    });
  });

  group('toInternational', () {
    test('huongeza +255 mara moja tu', () {
      expect(TzPhoneValidator.toInternational('0712345678'), '+255712345678');
      expect(
        TzPhoneValidator.toInternational('+255712345678'),
        '+255712345678',
      );
    });
  });

  group('detectProvider', () {
    test('huipata M-Pesa kwa 74/75/76', () {
      expect(
        TzPhoneValidator.detectProvider('0745123456'),
        PaymentProvider.mpesa,
      );
      expect(
        TzPhoneValidator.detectProvider('0754123456'),
        PaymentProvider.mpesa,
      );
      expect(
        TzPhoneValidator.detectProvider('0765123456'),
        PaymentProvider.mpesa,
      );
    });

    test('huipata Tigo Pesa kwa 71/65/67', () {
      expect(
        TzPhoneValidator.detectProvider('0712123456'),
        PaymentProvider.tigopesa,
      );
      expect(
        TzPhoneValidator.detectProvider('0655123456'),
        PaymentProvider.tigopesa,
      );
    });

    test('huipata Airtel Money kwa 78/69', () {
      expect(
        TzPhoneValidator.detectProvider('0786123456'),
        PaymentProvider.airtelMoney,
      );
    });

    test('huipata Halopesa kwa 62', () {
      expect(
        TzPhoneValidator.detectProvider('0622123456'),
        PaymentProvider.halopesa,
      );
    });

    test('hurudisha null kwa kiambishi kisichojulikana', () {
      expect(TzPhoneValidator.detectProvider('0512345678'), isNull);
      expect(TzPhoneValidator.detectProvider(''), isNull);
    });
  });

  group('PaymentProvider', () {
    test('kadi haihitaji namba ya simu', () {
      expect(PaymentProvider.card.requiresPhoneNumber, isFalse);
      expect(PaymentProvider.mpesa.requiresPhoneNumber, isTrue);
    });

    test('mobileMoney haijumuishi kadi', () {
      expect(
        PaymentProvider.mobileMoney.contains(PaymentProvider.card),
        isFalse,
      );
      expect(PaymentProvider.mobileMoney.length, 4);
    });

    test('fromId hupata kwa id ya API', () {
      expect(PaymentProvider.fromId('mpesa'), PaymentProvider.mpesa);
      expect(PaymentProvider.fromId('hakuipo'), isNull);
    });
  });
}
