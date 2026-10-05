import 'package:flutter/material.dart';

import '../../../core/models/user_model.dart';
import '../../../core/providers/network_image/custom_network_image_param.dart';
import '../../../core/tools/functions/color_functions.dart';
import '../../../core/tools/functions/string_functions.dart';
import 'custom_network_image.dart';

class UserAvatar extends StatelessWidget {
  final UserModel userData;
  final double radius;
  final double textSize;
  final Color? backgroundColor;

  const UserAvatar({
    required this.userData,
    super.key,
    this.radius = 80.0,
    this.textSize = 32.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = userData.avatar;

    if (avatar != null && avatar.isNotEmpty) {
      return ClipOval(
        child: CustomNetworkImage(
          param: CustomNetworkImageParam(
            src: avatar,
            sync: true,
            width: radius * 2,
            height: radius * 2,
          ),
        ),
      );
    }

    final name = userData.name ?? '';
    final color = backgroundColor ?? generateColorFromName(name);

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        getNameInitials(name),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: textSize,
          color: isColorDark(color) ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
