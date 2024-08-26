import 'package:driver/constants/app_strings.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:supercharged/supercharged.dart';

extension DynamicParsing on dynamic {
  //
  String currencyFormat() {
    final uiConfig = AppStrings.uiConfig;
    if (uiConfig != null && uiConfig["currency"] != null) {
      //
      final thousandSeparator = uiConfig["currency"]["format"] ?? ",";
      final decimalSeparator = uiConfig["currency"]["decimal_format"] ?? ".";
      final decimals = uiConfig["currency"]["decimals"];
      final currencyLOCATION = uiConfig["currency"]["location"] ?? 'left';
      final decimalsValue = "".padLeft(decimals.toString().toInt() ?? 0, "0");

      //
      //
      final values =
          toString().split(" ").join("").split(AppStrings.currencySymbol);

      //
      CurrencyFormatterSettings currencySettings = CurrencyFormatterSettings(
        symbol: AppStrings.currencySymbol,
        symbolSide: currencyLOCATION.toLowerCase() == "left"
            ? SymbolSide.left
            : SymbolSide.right,
        thousandSeparator: thousandSeparator,
        decimalSeparator: decimalSeparator,
      );

      return CurrencyFormatter.format(
        values[1],
        currencySettings,
        decimal: decimalsValue.length,
        enforceDecimals: true,
      );
    } else {
      return toString();
    }
  }

  //
  String currencyValueFormat() {
    final uiConfig = AppStrings.uiConfig;
    if (uiConfig != null && uiConfig["currency"] != null) {
      final thousandSeparator = uiConfig["currency"]["format"] ?? ",";
      final decimalSeparator = uiConfig["currency"]["decimal_format"] ?? ".";
      final decimals = uiConfig["currency"]["decimals"];
      final decimalsValue = "".padLeft(decimals.toString().toInt() ?? 0, "0");
      final values = toString().split(" ").join("");

      //
      CurrencyFormatterSettings currencySettings = CurrencyFormatterSettings(
        symbol: "",
        symbolSide: SymbolSide.right,
        thousandSeparator: thousandSeparator,
        decimalSeparator: decimalSeparator,
      );
      return CurrencyFormatter.format(
        values,
        currencySettings,
        decimal: decimalsValue.length,
        enforceDecimals: true,
      );
    } else {
      return toString();
    }
  }

  //
  String fill(List values) {
    //
    String data = toString();
    for (var value in values) {
      data = data.replaceFirst("%s", value.toString());
    }
    return data;
  }
}
