/// 水滸伝戦略ゲーム イベント通知ウィジェット
/// フェーズ2: イベントシステムのUI表示
library;

import 'package:flutter/material.dart';

import '../../models/game_events.dart';

/// イベント通知ダイアログ
class EventNotificationDialog extends StatelessWidget {
  const EventNotificationDialog({
    super.key,
    required this.event,
    required this.onChoiceSelected,
  });

  final GameEvent event;
  final Function(EventChoice) onChoiceSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          _getEventIcon(event.type),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          ...event.choices.map((choice) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onChoiceSelected(choice);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                    ),
                    child: Text(
                      choice.text,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _getEventIcon(EventType type) {
    switch (type) {
      case EventType.heroEncounter:
        return const Icon(Icons.person_add, color: Colors.blue, size: 24);
      case EventType.historical:
        return const Icon(Icons.history_edu, color: Colors.amber, size: 24);
      case EventType.random:
        return const Icon(Icons.casino, color: Colors.green, size: 24);
      case EventType.battle:
        return const Icon(Icons.local_fire_department,
            color: Colors.red, size: 24);
      case EventType.diplomatic:
        return const Icon(Icons.handshake, color: Colors.purple, size: 24);
    }
  }
}

/// イベントログパネル
class EventLogPanel extends StatelessWidget {
  const EventLogPanel({
    super.key,
    required this.recentEvents,
  });

  final List<String> recentEvents;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '最近の出来事',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: recentEvents.isEmpty
                ? const Center(
                    child: Text(
                      'まだ出来事がありません',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: recentEvents.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${recentEvents[index]}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
