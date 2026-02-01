import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';

enum NavigationBarItems {
  home(icon: Icons.home_rounded),
  mosque(icon: Icons.mosque_rounded),
  prayers(icon: Icons.schedule_rounded),
  quran(icon: Icons.import_contacts_outlined),
  more(icon: Icons.menu_rounded);

  const NavigationBarItems({required this.icon});
  final dynamic icon;

  String get label {
    return switch (this) {
      home => "Home",
      mosque => "Mosque",
      prayers => LocaleKeys.schedule.tr(),
      quran => "Quran",
      more => LocaleKeys.more.tr()
    };
  }
}
