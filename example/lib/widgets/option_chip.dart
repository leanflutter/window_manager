import 'package:flutter/widgets.dart';

import 'palette.dart';

/// A small mouse-only choice: every setting in the example is one of these,
/// so a GUI test or a demo script never needs the keyboard. Labels are plain
/// text (no icon font), which also lets a UI probe find them by name.
class OptionChip extends StatefulWidget {
  const OptionChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;

  /// Null disables the chip.
  final VoidCallback? onTap;

  @override
  State<OptionChip> createState() => _OptionChipState();
}

class _OptionChipState extends State<OptionChip> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final enabled = widget.onTap != null;
    final foreground = !enabled
        ? palette.muted.withValues(alpha: 0.45)
        : widget.selected
        ? palette.accent
        : palette.text;
    final background = widget.selected
        ? palette.accentSurface
        : (_hovered && enabled)
        ? palette.hover
        : const Color(0x00000000);
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 80),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.selected ? palette.accent : palette.border,
              ),
            ),
            child: Text(
              widget.label,
              style: TextStyle(fontSize: 11.5, height: 1.2, color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}

/// One labelled row of [OptionChip]s.
class OptionRow extends StatelessWidget {
  const OptionRow({super.key, required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 66,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: palette.muted),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 5,
              runSpacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Muted remark placed after the chips of a row.
class Hint extends StatelessWidget {
  const Hint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 11, color: Palette.of(context).muted),
  );
}
