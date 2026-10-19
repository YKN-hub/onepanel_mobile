import 'package:flutter/material.dart';
import 'package:onepanel_mobile/core/i18n/app_localizations.dart';

/// 国际化工具类
class I18n {
  static String tr(BuildContext context, String key) {
    return AppLocalizations.of(context)?.tr(key) ?? key;
  }
}
