import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/misc.dart';

/// Kerangka Login/Sign Up: latar statis, logo, judul, tab Log In | Sign Up, kartu putih.
class AuthFrame extends StatelessWidget {
  const AuthFrame({
    super.key,
    required this.active,
    required this.child,
    this.padBottom = 32,
  });

  final String active;
  final Widget child;
  final double padBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.primary900,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg/auth.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      C.primary900.withValues(alpha: .8),
                      C.primary900.withValues(alpha: .3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, box) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: box.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 48),
                          SvgPicture.asset('assets/images/logo.svg', height: 53),
                          const SizedBox(height: 14),
                          Text('Get Started Now', style: T.h5(Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            'Create an account or log in.',
                            style: T.b3(Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                for (final tab in const [
                                  ('login', 'Log In', '/login'),
                                  ('signup', 'Sign Up', '/signup'),
                                ])
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => context.go(tab.$3),
                                      child: Container(
                                        height: 32,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: active == tab.$1
                                              ? Colors.white
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: active == tab.$1
                                              ? C.shadowCard
                                              : null,
                                        ),
                                        child: Text(
                                          tab.$2,
                                          style: T.b4(
                                            active == tab.$1
                                                ? C.grey800
                                                : Colors.white,
                                          ).copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              padding:
                                  EdgeInsets.fromLTRB(24, 24, 24, padBottom),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              child: child,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class SocialLogin extends StatelessWidget {
  const SocialLogin({super.key, this.myits});

  final String? myits;

  @override
  Widget build(BuildContext context) {
    Widget social(String label, Widget icon) {
      return Expanded(
        child: GestureDetector(
          onTap: () => showSnack(context, '$label login belum diaktifkan.'),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: C.grey200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 8),
                Text(
                  label,
                  style: T.b4(C.grey800).copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Divider(color: C.grey100)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Or login with', style: T.b3(C.grey500)),
            ),
            const Expanded(child: Divider(color: C.grey100)),
          ],
        ),
        if (myits != null) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/login-its/email'),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF00589F),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/logo-its.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    myits!,
                    style:
                        T.b4(Colors.white).copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            social('Google', const AppIcon('globe', size: 20)),
            const SizedBox(width: 8),
            social('Apple', const AppIcon('user', size: 20)),
          ],
        ),
      ],
    );
  }
}

class MyItsCard extends StatelessWidget {
  const MyItsCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.primary900,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/images/logo-its.svg',
                          height: 36,
                        ),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}