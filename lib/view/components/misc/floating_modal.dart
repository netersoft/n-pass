import 'package:material_ui/material_ui.dart';

class FloatingModal extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FloatingModal({required this.child, super.key, this.backgroundColor});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: backgroundColor,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    ),
  );
}

Future<T?> showFloatingModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  elevation: 0,
  builder: (context) => FloatingModal(backgroundColor: backgroundColor, child: builder(context)),
);
