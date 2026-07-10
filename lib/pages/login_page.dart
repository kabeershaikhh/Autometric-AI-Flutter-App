import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../components/my_social_button.dart';
import '../components/my_textfield.dart';
import '../constants/app_colors.dart';


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

    final leftWidth = (screenWidth * 0.28).clamp(300.0, 430.0);

    final cardWidth = (screenWidth * 0.34).clamp(380.0, 470.0);

    final gap = (screenWidth * 0.06).clamp(40.0, 150.0);

    final horizontalPadding =
    (screenWidth * 0.05).clamp(20.0, 70.0);

    return Stack(
      children: [
        /// Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6333F3),
                Color(0xFFA07DFF),
                Color(0xFFDBB7FF),
              ],
            ),
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
                          padding: const EdgeInsets.only(top: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                  'Smart Car Valuation',
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

  void login(BuildContext context) async{
    final authService = AuthService();

    try{
      await authService.signInWithEmailAndPassword(
          _emailController.text,
          _pwdController.text);
    }
    //catch any errors
    catch(e){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
        title: Text(e.toString()),
        ),
      );
    }
  }

  //reset password for user
  void forgotPassword(BuildContext context) {
    final  resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: MyTextField(
            controller: resetEmailController,
            hint: "Enter your email",
            icon: Icons.email_outlined,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await AuthService().sendPasswordResetEmail(
                  resetEmailController.text,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Password reset email sent.",
                    ),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(e.toString()),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text("Send",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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
            onPressed: (){
              login(context);
            },
            child: const Row(
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
                  text: "Don't have an account? ",
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: widget.onTap,
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