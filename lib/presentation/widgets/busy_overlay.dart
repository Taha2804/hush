import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_controller.dart';
import '../../services/supabase/multiplayer_providers.dart';
import 'hush_loader.dart';
import 'motion.dart';

/// A loading message set by a screen while one of its buttons is working.
final manualBusyProvider = NotifierProvider<ManualBusy, String?>(ManualBusy.new);

class ManualBusy extends Notifier<String?> {
  @override
  String? build() => null;

  /// Shows the Hushbug loader with [message] until [action] finishes.
  Future<T> run<T>(String message, Future<T> Function() action) async {
    state = message;
    try {
      return await action();
    } finally {
      state = null;
    }
  }
}

/// Covers the app with the Hushbug loader whenever a button's action is in
/// progress anywhere: starting games, joining rooms, sending clues, voting,
/// moving between rounds. It also blocks taps so nothing is pressed twice.
class HushbugBusyOverlay extends ConsumerWidget {
  const HushbugBusyOverlay({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manual = ref.watch(manualBusyProvider);
    final local = ref.watch(gameProvider.select((g) => g.loading));
    final online = ref.watch(onlineGameProvider.select((g) => g.busy));
    final lobby = ref.watch(onlineLobbyProvider.select((l) => l.isLoading));
    final message = manual ??
        (local
            ? 'Dealing the cards…'
            : online
                ? 'One moment…'
                : lobby
                    ? 'Connecting to the room…'
                    : null);

    return Stack(children: [
      child,
      Positioned.fill(
        child: IgnorePointer(
          ignoring: message == null,
          child: AnimatedOpacity(
            opacity: message == null ? 0 : 1,
            duration: motionDuration(context, 160),
            child: message == null
                ? const SizedBox.shrink()
                // Material gives the loader's text the app's normal styling;
                // this sits above the navigator, outside any screen.
                : Material(
                    color: const Color(0xCC140A2C),
                    child: Center(child: HushbugLoader(size: 110, text: message)),
                  ),
          ),
        ),
      ),
    ]);
  }
}
