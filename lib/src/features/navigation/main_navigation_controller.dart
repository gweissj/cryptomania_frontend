import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MainTab { home, trade, market, favorites, wallet }

final mainTabProvider = StateProvider<MainTab>((_) => MainTab.home);
