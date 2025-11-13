import 'package:flutter/material.dart';
import 'register_page.dart';
import 'dashboard_page.dart';
import 'database_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      try {
        final user = await _databaseHelper.loginUser(
          emailController.text.trim(),
          passwordController.text,
        );
        if (user != null) {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage(userData: user)),
            (route) => false,
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email ou mot de passe incorrect'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) { setState(() { _isLoading = false; }); }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Login', style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/door_image.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Veuillez entrer votre email';
                    if (!value.contains('@')) return 'Veuillez entrer un email valide';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email', labelStyle: const TextStyle(color: Color(0xFF718096)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF4299E1))),
                    prefixIcon: const Icon(Icons.email, color: Color(0xFF718096)),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Veuillez entrer votre mot de passe';
                    if (value.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password', labelStyle: const TextStyle(color: Color(0xFF718096)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF4299E1))),
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF718096)),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xFF4299E1)),
                          ),
                        ),
                        child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4299E1))),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4299E1),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Center(
                  child: Column(children: [
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _buildSocialIcon(Icons.music_note, const Color(0xFF000000)),
                      const SizedBox(width: 20),
                      _buildSocialIcon(Icons.facebook, const Color(0xFF1877F2)),
                      const SizedBox(width: 20),
                      _buildSocialIcon(Icons.camera_alt, const Color(0xFFE4405F)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}