import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../components/my_social_button.dart';
import '../components/my_textfield.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  final void Function()? onTap;

  const RegisterPage({super.key,required this.onTap});

  bool get isWeb => kIsWeb;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (kIsWeb && constraints.maxWidth >= 950) {
            return WebRegisterLayout(onTap: onTap);
          } else {
            return AndroidRegisterLayout(onTap: onTap);
          }
        },
      ),
    );
  }
}
///////////////////////////////////////////////////////////
/// WEB REGISTER LAYOUT
////////////////////////////////////////////////////////////

class WebRegisterLayout extends StatelessWidget {
  final void Function()? onTap;

  const WebRegisterLayout({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    final leftWidth = (screenWidth * 0.28).clamp(300.0, 430.0);

    final cardWidth = (screenWidth * 0.34).clamp(380.0, 470.0);

    final gap = (screenWidth * 0.06).clamp(40.0, 150.0);

    final horizontalPadding =
    (screenWidth * 0.05).clamp(20.0, 70.0);

    return Stack(
      children: [
        ////////////////////////////////////////////////////
        /// Background
        ////////////////////////////////////////////////////

        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6236FF),
                Color(0xFF8D6AF8),
                Color(0xFFD9C5FF),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),

        Positioned(
          top: -120,
          right: -80,
          child: circleDecoration(320),
        ),

        Positioned(
          bottom: -140,
          left: -90,
          child: circleDecoration(360),
        ),

        ////////////////////////////////////////////////////
        /// CONTENT
        ////////////////////////////////////////////////////

        SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: Center(
                child: Padding(
                  padding:  EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 40,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      ////////////////////////////////////////////////////
                      /// LEFT SIDE
                      ////////////////////////////////////////////////////

                      SizedBox(
                        width: leftWidth,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Column(
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
                                "Smart Car Valuation",
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white70,
                                ),
                              ),

                              const SizedBox(height: 45),

                              const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "AI Powered Analysis",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Accurate Car Valuation",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Evaluation History",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
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
                          child: RegisterForm(
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
/// ANDROID REGISTER LAYOUT
////////////////////////////////////////////////////////////

class AndroidRegisterLayout extends StatelessWidget {
  final void Function()? onTap;

  const AndroidRegisterLayout({
    super.key,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// BACKGROUND
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF7C4DFF),
                Color(0xFF9E7BFF),
                Color(0xFFFDF7FF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

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

                /// LOGO
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Start your smart valuation journey',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 40),

                /// REGISTER CARD
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
                  child: RegisterForm(
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
/// REGISTER FORM
////////////////////////////////////////////////////////////

class RegisterForm extends StatefulWidget {
  final void Function()? onTap;
  final bool mobileMode;

  const RegisterForm({
    super.key,
    required this.mobileMode,
    required this.onTap,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();

  bool isLoading = false;

  // register method
  void register(BuildContext context) async {
    final _authService = AuthService();

    if (_pwdController.text == _confirmPwdController.text) {
      setState(() {
        isLoading = true;
      });
      try {
        await _authService.signUpWithEmailAndPassword(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _pwdController.text,
        );
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
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords do not match."),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: widget.mobileMode ? 28 : 34,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D1A22),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Fill in the details below to get started.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 32),

        /// FULL NAME
        const Text(
          'Full Name',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        MyTextField(
          controller: _nameController,
          hint: "Name",
          icon: Icons.person_outlined,
        ),

        const SizedBox(height: 20),

        /// EMAIL
        const Text(
          'Email Address',
          style: TextStyle(fontWeight: FontWeight.w600),
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
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        MyTextField(
          controller: _pwdController,
          hint: "Password",
          icon: Icons.lock_outline,
          isPassword: true,
        ),

        const SizedBox(height: 20),

        /// CONFIRM PASSWORD
        const Text(
          'Confirm Password',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        MyTextField(
          controller: _confirmPwdController,
          hint: "Confirm Password",
          icon: Icons.lock_outline,
          isPassword: true,
        ),

        const SizedBox(height: 30),

        /// REGISTER BUTTON
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
            onPressed: isLoading ? null : () => register(context),
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
                        'Create Account',
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
          child: MySocialButton(
            imagePath: 'assets/google.png',
            label: 'Continue with Google',
            onPressed: () {
              // Google Sign-In
            },
          ),
        ),

        const SizedBox(height: 28),

        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black54),
              children: [
                const TextSpan(
                  text: "Already have an account? ",
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Sign in",
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