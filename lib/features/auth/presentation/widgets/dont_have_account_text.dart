import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/styles.dart';
import 'package:easy_localization/easy_localization.dart';

class DontHaveAccountText extends StatelessWidget {
  const DontHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'dont_have_account'.tr(),
            style: TextStyles.font13GrayRegular,
          ),
          TextSpan(
            text: 'signup'.tr(),
            style: TextStyles.font13BlueSemiBold,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(context, Routes.signUpScreen);
              },
          ),
        ],
      ),
    );
  }
}
