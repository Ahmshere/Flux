import 'package:home_widget/home_widget.dart';
import '../../features/currency/domain/entities/rate.dart';

class HomeWidgetService {
  static const _appGroupId = 'com.converter.whitefox.cur_converter';
  static const _widgetName = 'FluxRateWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  static Future<void> update({
    required Rate from,
    required Rate to,
    required double amount,
    required double result,
    required double rate,
  }) async {
    // Банковский диапазон +2% и +5%
    final bankLow  = rate * 1.02;
    final bankHigh = rate * 1.05;
    final bankText =
        '🏦 ≈ ${_fmtRate(bankLow)}–${_fmtRate(bankHigh)} ${to.code} in banks';

    await Future.wait([
      HomeWidget.saveWidgetData<String>('from_code',   from.code),
      HomeWidget.saveWidgetData<String>('to_code',     to.code),
      HomeWidget.saveWidgetData<String>('from_flag',   from.flag),
      HomeWidget.saveWidgetData<String>('to_flag',     to.flag),
      HomeWidget.saveWidgetData<String>('amount_str',  '${_fmt(amount)} ${from.code}'),
      HomeWidget.saveWidgetData<String>('result_str',  _fmt(result)),
      HomeWidget.saveWidgetData<String>('rate_str',    'ECB: 1 ${from.code} = ${_fmtRate(rate)} ${to.code}'),
      HomeWidget.saveWidgetData<String>('bank_rate',   bankText),
      HomeWidget.saveWidgetData<String>('updated_at',  _timeNow()),
    ]);

    await HomeWidget.updateWidget(androidName: _widgetName);
  }

  static String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    if (v < 0.001)    return v.toStringAsFixed(6);
    if (v < 1)        return v.toStringAsFixed(4);
    return v.toStringAsFixed(2);
  }

  static String _fmtRate(double v) {
    if (v < 0.0001) return v.toStringAsFixed(8);
    if (v < 0.01)   return v.toStringAsFixed(6);
    if (v < 1)      return v.toStringAsFixed(4);
    return v.toStringAsFixed(4);
  }

  static String _timeNow() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2,'0')}:'
        '${now.minute.toString().padLeft(2,'0')}';
  }
}