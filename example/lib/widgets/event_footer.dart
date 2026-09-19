import 'package:flutter/widgets.dart';

import '../window_controller.dart';
import 'option_chip.dart';
import 'palette.dart';

/// The last event in large type (readable in a video) over a short log.
class EventFooter extends StatelessWidget {
  const EventFooter({super.key, required this.controller});

  final WindowController controller;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      height: 92,
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 6),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.lastEvent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              OptionChip(label: 'Clear log', onTap: controller.clearLog),
            ],
          ),
          const SizedBox(height: 3),
          for (final line in controller.log.take(3))
            Text(
              line,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: palette.mono,
            ),
        ],
      ),
    );
  }
}
