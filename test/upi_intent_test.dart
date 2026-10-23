import 'package:flutter_test/flutter_test.dart';
import 'package:upi_intent_cred/upi_intent.dart';

void main() {
  group('UpiValidator', () {
    test('validates correct VPAs', () {
      expect(UpiValidator.isValidVpa('user@upi'), isTrue);
      expect(UpiValidator.isValidVpa('9876543210@paytm'), isTrue);
      expect(UpiValidator.isValidVpa('john.doe@oksbi'), isTrue);
      expect(UpiValidator.isValidVpa('test_123@ybl'), isTrue);
    });

    test('rejects invalid VPAs', () {
      expect(UpiValidator.isValidVpa(''), isFalse);
      expect(UpiValidator.isValidVpa('notavpa'), isFalse);
      expect(UpiValidator.isValidVpa('@upi'), isFalse);
      expect(UpiValidator.isValidVpa('user@'), isFalse);
    });

    test('validates amounts correctly', () {
      expect(UpiValidator.isValidAmount(1.0), isTrue);
      expect(UpiValidator.isValidAmount(99.99), isTrue);
      expect(UpiValidator.isValidAmount(100000), isTrue);
      expect(UpiValidator.isValidAmount(0), isFalse);
      expect(UpiValidator.isValidAmount(-1), isFalse);
      expect(UpiValidator.isValidAmount(100001), isFalse);
    });

    test('converts phone to VPA', () {
      expect(
        UpiValidator.phoneToVpa('9876543210', 'paytm'),
        '9876543210@paytm',
      );
    });

    test('extracts bank handle from VPA', () {
      expect(UpiValidator.bankHandle('user@oksbi'), 'oksbi');
      expect(UpiValidator.bankHandle('notavpa'), isNull);
    });
  });

  group('UpiUrlBuilder', () {
    test('builds correct UPI URL', () {
      final url = UpiIntent.buildUpiUrl(
        UpiPayment(
          payeeVpa: 'merchant@upi',
          payeeName: 'Test Shop',
          amount: 99.00,
          transactionNote: 'Order 1',
        ),
      );
      expect(url, contains('upi://pay?'));
      expect(url, contains('pa=merchant@upi'));
      expect(url, contains('am=99.00'));
      expect(url, contains('cu=INR'));
    });

    test('builds URL without optional fields', () {
      final url = UpiIntent.buildUpiUrl(
        UpiPayment(payeeVpa: 'shop@upi', payeeName: 'Shop'),
      );
      expect(url, contains('pa=shop@upi'));
      expect(url, isNot(contains('am=')));
    });
  });

  group('UpiResponse', () {
    test('parses success response', () {
      final r = UpiResponse.fromResponseString(
        'Status=success&txnId=TXN123&ApprovalRefNo=ABC456',
      );
      expect(r.isSuccess, isTrue);
      expect(r.transactionId, 'TXN123');
      expect(r.approvalRefNo, 'ABC456');
    });

    test('parses failure response', () {
      final r = UpiResponse.fromResponseString('Status=failure');
      expect(r.isFailure, isTrue);
      expect(r.isSuccess, isFalse);
    });

    test('handles unknown status', () {
      final r = UpiResponse.fromResponseString('Status=weird');
      expect(r.status, UpiTransactionStatus.unknown);
    });
  });

  group('UpiPayment', () {
    test('creates payment model correctly', () {
      const p = UpiPayment(
        payeeVpa: 'test@upi',
        payeeName: 'Test',
        amount: 50.0,
      );
      expect(p.payeeVpa, 'test@upi');
      expect(p.amount, 50.0);
    });
  });
}
