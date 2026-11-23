// ignore_for_file: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/misc.dart';
import '../../core/utils/format.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.grey50,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/bg/splash.jpg'), fit: BoxFit.cover)),
        child: SafeArea(
          child: LayoutBuilder(builder: (context, box) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(56, 231, 56, 32),
                  child: Column(children: [
                    SvgPicture.asset('assets/images/logo.svg'),
                    const SizedBox(height: 12),
                    Text('Welcome to\nRoomaster.', textAlign: TextAlign.center, style: T.h5(C.primary900)),
                    const SizedBox(height: 4),
                    Text('Pinjam Ruangan Langsung Beres,\nLapor Kerusakan Anti Stres.', textAlign: TextAlign.center, style: T.b3(C.grey800)),
                    const SizedBox(height: 56),
                    AppButton('Get Started', onPressed: () => context.go('/signup'), size: BtnSize.medium, expand: true),
                    const SizedBox(height: 12),
                    AppButton('Log In', onPressed: () => context.go('/login'), size: BtnSize.medium, expand: true, bg: Colors.white, fg: C.grey800),
                  ]),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
