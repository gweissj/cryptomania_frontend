import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MainTab { home, trade, market, sell, wallet }

final mainTabProvider = StateProvider<MainTab>((_) => MainTab.home);
