import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/features/stories/presentation/pages/story_detail_page.dart';

void main() {
  test('reading and recorded audio availability are independent', () {
    const report = OfflineReport(checkedCount: 2, missing: [], audioMissing: 1);
    expect(report.isComplete, isTrue);
    expect(report.hasCompleteAudio, isFalse);
  });

  test('complete audio does not hide missing reading assets', () {
    const report = OfflineReport(checkedCount: 2, missing: ['cover'], audioMissing: 0);
    expect(report.isComplete, isFalse);
    expect(report.hasCompleteAudio, isTrue);
  });

  test('unknown manifest cannot report reading or audio as available', () {
    const report = OfflineReport.unknown();
    expect(report.isComplete, isFalse);
    expect(report.hasCompleteAudio, isFalse);
  });
}
