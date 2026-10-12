import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../components/google_sign_in_button.dart';
import '../components/my_textfield.dart';
import '../constants/app_colors.dart';
import '../components/auth_web_spacing.dart';


class LoginPage extends StatelessWidget {

  final void Function()? onTap;

  const LoginPage({super.key,required this.onTap});

  bool get isWeb => kIsWeb;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (kIsWeb && constraints.maxWidth >= 950) {
            return WebLoginLayout(onTap: onTap);
          } else {
            return AndroidLoginLayout(onTap: onTap);
          }
        },
      ),
    );
  }
}



////////////////////////////////////////////////////////////
/// WEB LAYOUT
////////////////////////////////////////////////////////////

class WebLoginLayout extends StatelessWidget {
  final void Function()? onTap;

  const WebLoginLayout({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    final leftWidth = AuthWebSpacing.panelWidth(
      screenWidth, AuthWebSpacing.brandingMaxWidth,
    );

    final cardWidth = AuthWebSpacing.panelWidth(
      screenWidth, AuthWebSpacing.cardMaxWidth,
    );

    final gap = AuthWebSpacing.gap(screenWidth);

    const horizontalPadding = AuthWebSpacing.horizontalPadding;

    return Stack(
      children: [
        /// Background
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.authWebGradient,
          ),
        ),

        /// Decorative circles
        Positioned(
          top: -120,
          right: -80,
          child: circleDecoration(320),
        ),

        Positioned(
          bottom: -140,
          left: -100,
          child: circleDecoration(380),
        ),

        SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.paddingOf(context).vertical,
              ),
              child: Center(
                child: Padding(
                  padding:  EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: AuthWebSpacing.verticalPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // Do not centre branding against a form taller than the viewport.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      ////////////////////////////////////////////////////
                      /// LEFT SIDE
                      ////////////////////////////////////////////////////
                      SizedBox(
                        width: leftWidth,
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.12),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset(
                                    "assets/AutoMetricAI.png",
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              const Text(
                                "AutoMetric AI",
                                style: TextStyle(
                                  fontSize: 46,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "Smart Car Price Estimation",
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white70,
                                ),
                              ),

                              const SizedBox(height: 42),

                              const _BenefitRow(
                                icon: Icons.auto_awesome_rounded,
                                text: 'AI-Powered Estimation',
                              ),

                              const SizedBox(height: 18),

                              const _BenefitRow(
                                icon: Icons.build_outlined,
                                text: 'Smart Car Maintenance Management',
                              ),

                              const SizedBox(height: 18),

                              const _BenefitRow(
                                icon: Icons.bookmark_outline_rounded,
                                text: 'Save Evaluations Efficiently',
                              ),

                            ],
                          ),
                        ),
                      ),

                       SizedBox(width: gap),

                      ////////////////////////////////////////////////////
                      /// RIGHT SIDE
                      ////////////////////////////////////////////////////

                      SizedBox(
                        width: cardWidth,
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.08),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: LoginForm(
                            mobileMode: false,
                            onTap: onTap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// ANDROID LAYOUT
////////////////////////////////////////////////////////////

class AndroidLoginLayout extends StatelessWidget {

  final void Function()? onTap;

  const AndroidLoginLayout({
    super.key,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Background
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.authMobileGradient,
          ),
        ),

        /// Decorative circles
        Positioned(
          top: -80,
          right: -50,
          child: circleDecoration(220),
        ),

        Positioned(
          bottom: -100,
          left: -60,
          child: circleDecoration(260),
        ),

        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 30),

                /// Logo
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/AutoMetricAI.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'AutoMetric AI',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Smart Car Price Estimation',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 40),

                /// Login Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: LoginForm(
                    mobileMode: true,
                    onTap: onTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// LOGIN FORM
////////////////////////////////////////////////////////////

class LoginForm extends StatefulWidget {
  final void Function()? onTap;
  final bool mobileMode;

  const LoginForm({
    super.key,
    required this.mobileMode,
    required this.onTap,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  bool isLoading = false;
  bool isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  void login(BuildContext context) async {
    final authService = AuthService();

    setState(() {
      isLoading = true;
    });

    try {
      await authService.signInWithEmailAndPassword(
          _emailController.text,
          _pwdController.text);
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  //reset password for user
  void forgotPassword(BuildContext context) {
    final  resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool isResetting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Reset Password"),
              content: MyTextField(
                controller: resetEmailController,
                hint: "Enter your email",
                icon: Icons.email_outlined,
              ),
              actions: [
                TextButton(
                  onPressed: isResetting ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: isResetting
                      ? null
                      : () async {
                          setDialogState(() {
                            isResetting = true;
                          });
                          try {
                            await AuthService().sendPasswordResetEmail(
                              resetEmailController.text,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Password reset email sent.",
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(e.toString()),
                                ),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setDialogState(() {
                                isResetting = false;
                              });
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isResetting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Send",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: widget.mobileMode ? 28 : 34,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D1A22),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Access your expert car valuation dashboard.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 32),

        /// EMAIL
        const Text(
          'Email Address',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        MyTextField(
          controller: _emailController,
          hint: "Email",
          icon: Icons.email_outlined,
        ),

        const SizedBox(height: 20),

        /// PASSWORD
        const Text(
          'Password',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        MyTextField(
          controller: _pwdController,
          hint: "Password",
          icon: Icons.lock_outline,
          isPassword: true,
        ),

        const SizedBox(height: 14),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              forgotPassword(context);
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: Color(0xFF7C4DFF),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// LOGIN BUTTON
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 8,
            ),
            onPressed: isLoading || isGoogleLoading ? null : () => login(context),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 30),

        Row(
          children: [
            Expanded(child: divider()),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Or continue with',
                style: TextStyle(color: Colors.black45),
              ),
            ),
            Expanded(child: divider()),
          ],
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: GoogleSignInButton(
            enabled: !isLoading && !isGoogleLoading,
            onBusyChanged: (busy) => setState(() => isGoogleLoading = busy),
          ),
        ),

        const SizedBox(height: 28),

        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black54),
              children: [
                const TextSpan(
                  text: "Don't have an account? ",
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: isLoading || isGoogleLoading ? null : widget.onTap,
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Color(0xFF7C4DFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// HELPERS
////////////////////////////////////////////////////////////

Widget divider() {
  return Container(
    height: 1,
    color: Colors.black12,
  );
}



Widget glassCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.20),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: Colors.white.withOpacity(0.25),
      ),
    ),
    child: child,
  );
}

Widget glassSmallCard(IconData icon, String title) {
  return glassCard(
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF7C4DFF).withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.verified,
            color: Color(0xFF7C4DFF),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget circleDecoration(double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.08),
    ),
  );
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
      ],
    );
  }
}
