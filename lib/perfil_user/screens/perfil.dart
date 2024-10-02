import 'package:flutter/material.dart';

class PanaraInfoDialogWidget extends StatelessWidget {
  final String? title;
  final String message;
  final String? imagePath;
  final String buttonText;
  final VoidCallback onTapDismiss;
  final PanaraDialogType panaraDialogType;
  final Color? containerColor;
  final Color? color;
  final Color? textColor;
  final Color? buttonTextColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  /// If you don't want any icon or image, you toggle it to true.
  final bool noImage;
  const PanaraInfoDialogWidget({
    super.key,
    this.title,
    required this.message,
    required this.buttonText,
    required this.onTapDismiss,
    required this.panaraDialogType,
    this.textColor = const Color(0xFF707070),
    this.containerColor = Colors.white,
    this.color = const Color(0xFF179DFF),
    this.buttonTextColor,
    this.imagePath,
    this.padding =
        const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 24),
    this.margin =
        const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 24),
    required this.noImage,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Card(
          elevation: 2,
          color: Colors.black,
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 340,
            ),
            margin: margin ?? const EdgeInsets.all(0),
            padding: padding ?? const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                if (!noImage)
                  Image.asset(
                    imagePath ?? 'assets/info.png',
                    package: imagePath != null ? null : 'panara_dialogs',
                    width: 110,
                    height: 110,
                    color: imagePath != null
                        ? null
                        : (panaraDialogType == PanaraDialogType.normal
                            ? PanaraColors.normal
                            : panaraDialogType == PanaraDialogType.success
                                ? PanaraColors.success
                                : panaraDialogType == PanaraDialogType.warning
                                    ? PanaraColors.warning
                                    : panaraDialogType == PanaraDialogType.error
                                        ? PanaraColors.error
                                        : color),
                  ),
                if (title != null)
                  Text(
                    title ?? "",
                    style: TextStyle(
                      fontSize: 24,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (title != null)
                  const SizedBox(
                    height: 5,
                  ),
                Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    height: 1.5,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30,
                ),
                PanaraButton(
                  buttonTextColor: buttonTextColor ?? Colors.white,
                  text: buttonText,
                  onTap: onTapDismiss,
                  bgColor: panaraDialogType == PanaraDialogType.normal
                      ? PanaraColors.normal
                      : panaraDialogType == PanaraDialogType.success
                          ? PanaraColors.success
                          : panaraDialogType == PanaraDialogType.warning
                              ? PanaraColors.warning
                              : panaraDialogType == PanaraDialogType.error
                                  ? PanaraColors.error
                                  : color ?? PanaraColors.normal,
                  isOutlined: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PanaraButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color bgColor;
  final Color buttonTextColor;
  final bool isOutlined;

  const PanaraButton({
    super.key,
    required this.text,
    this.onTap,
    required this.bgColor,
    required this.isOutlined,
    this.buttonTextColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOutlined ? Colors.white : bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: isOutlined ? Border.all(color: bgColor) : null,
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isOutlined ? bgColor : buttonTextColor,
            ),
          ),
        ),
      ),
    );
  }
}

enum PanaraDialogType { success, normal, warning, error, custom }

class PanaraColors {
  /// All the Colors used in the Dialog themes
  /// <h3>Hex Code: #61D800</h3>
  static Color success = const Color(0xFF61D800);

  /// <h3>Hex Code: #179DFF</h3>
  static Color normal = const Color(0xFF179DFF);

  /// <h3>Hex Code: #FF8B17</h3>
  static Color warning = const Color(0xFFFF8B17);

  /// <h3>Hex Code: #FF4D17</h3>
  static Color error = const Color(0xFFFF4D17);

  /// <h3>Hex Code: #707070</h3>
  static Color defaultTextColor = const Color(0xFF707070);
}
