import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sound_slice/resources/auth_methods.dart';
import 'package:sound_slice/responsive/mobile_screen.dart';
import 'package:sound_slice/responsive/responsive_layout_screen.dart';
import 'package:sound_slice/responsive/web_screen.dart';
import 'package:sound_slice/screens/signup_screen.dart';
import 'package:sound_slice/util/utils.dart';
import 'package:sound_slice/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
        email: _emailController.text, password: _passwordController.text);
    if (res == 'success') {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ResponsiveLayout(
                mobileScreenLayout: MobileScreenLayout(),
                webScreenLayout: WebScreenLayout(),
              ),
            ),
            (route) => false);

        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        showSnackBar(res, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Headphones image
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      color: const Color.fromRGBO(111, 37, 156, 0.8),
                      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
                      child: SvgPicture.asset(
                        'assets/headplogin.svg',
                        fit: BoxFit.cover,
                        colorBlendMode: BlendMode.overlay,
                      ),
                    ),
                    // Welcome text
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontSize: 24.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              
            ),
            // Login Form
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Enter your details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextFieldInput(
                    textEditingController: _emailController,
                    hintText: 'Enter your Email',
                    textInputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20.0),
                  TextFieldInput(
                    textEditingController: _passwordController,
                    hintText: 'Enter your Password',
                    isPass: true,
                    textInputType: TextInputType.text,
                  ),
                  const SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Implement forgot password functionality
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(111, 37, 156, 1),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        text: 'Don\'t have an account? ',
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              color: Color.fromRGBO(111, 37, 156, 1),
                            ),
                            // Implement navigation to sign up page
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
