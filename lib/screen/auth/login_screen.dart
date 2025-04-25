import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../service/apiservice/auth_service.dart';
import 'forgot_password_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final id      = _identifierController.text.trim();
    final isEmail = id.contains('@');
    final result  = await AuthService.loginUser(
      email:  isEmail ? id : null,
      mobile: !isEmail ? id : null,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    final ok         = result['status']     as bool;
    final msg        = result['message']    as String;
    final statusCode = result['statusCode'] as int;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) {
      // Fully logged in
      context.goNamed('main');  // or '/home'
    }
    else if (statusCode == 401) {
      // Not verified yet — use the server message to pick the screen
      final lower = msg.toLowerCase();
      if (lower.contains('mobile')) {
        context.goNamed(
          'mobile_verify',
        );
      } else if (lower.contains('email')) {
        context.goNamed(
          'email_verify'
        );
      }
    }
  }


  // Future<void> _login() async {
  //   context.go('/main');
  // }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
                child: Center(
                  child: Lottie.asset(
                    'assets/anim/anim_2.json',
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 60),

                      // Identifier Field
                      TextFormField(
                        controller: _identifierController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Email or Phone',
                          hintText: 'you@example.com or 0123456789',
                          prefixIcon: Icon(Icons.person, color: Colors.grey),
                          labelStyle: TextStyle(color: Colors.grey),
                          hintStyle: TextStyle(color: Colors.black45),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.amber, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.amber, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.redAccent, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter email or phone';
                          }
                          final t = val.trim();
                          if (t.contains('@')) {
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(t))
                              return 'Enter a valid email';
                          } else if (!RegExp(r'^[0-9]{10}$').hasMatch(t)) {
                            return 'Enter a valid 10-digit phone';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.lock, color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.amber, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.amber, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.redAccent, width: 2),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please enter password';
                          if (val.length < 6) return 'Password must be ≥ 6 chars';
                          return null;
                        },
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },

                          child: Text('Forgot Password?', style: TextStyle(color: Colors.grey)),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text('Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  )),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Signup link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ",
                              style: TextStyle(color: Colors.black54)),
                          GestureDetector(
                            onTap: () {
                              context.goNamed('register');
                            },

                            child: Text("Signup",
                                style: TextStyle(
                                  color: Color(0xFFFFA500),
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
