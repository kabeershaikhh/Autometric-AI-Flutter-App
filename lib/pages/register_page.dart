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
      body: isWeb
          ?  WebRegisterLayout(onTap: onTap,)
          :  AndroidRegisterLayout(onTap: onTap,),
    );
  }
}

////////////////////////////////////////////////////////////
/// WEB REGISTER LAYOUT
////////////////////////////////////////////////////////////

class WebRegisterLayout extends StatelessWidget {

  final void Function()? onTap;
  const WebRegisterLayout({super.key,required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// LEFT SIDE
        Expanded(
          flex: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?q=80&w=1600&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7C4DFF).withOpacity(0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    glassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Join AutoMetric AI',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Create your account and unlock intelligent car valuation insights.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: glassSmallCard(
                            Icons.analytics,
                            'AI Insights',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: glassSmallCard(
                            Icons.security,
                            'Secure Platform',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        /// RIGHT SIDE
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: SizedBox(
                  width: 420,
                  child: RegisterForm(
                    mobileMode: false,
                    onTap: onTap,
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

  // register method
  void register(BuildContext context) async{

    //get auth service
    final _authService = AuthService();
    //if passwords match create user
   if(_pwdController.text == _confirmPwdController.text) {
     try{
      await _authService.signUpWithEmailAndPassword(
         _nameController.text.trim(),
         _emailController.text.trim(),
         _pwdController.text,
       );
     } catch (e){
       showDialog(
         context: context,
         builder: (context) => AlertDialog(
           title: Text(e.toString()),
         ),
       );
     }
   }

   //if password doesnt match tell user to fix
   else{
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
            onPressed: () {
              register(context);
            },
            child: const Row(
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