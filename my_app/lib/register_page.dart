import 'package:flutter/material.dart';
import 'login_page.dart';
import 'database_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nomPrenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Variables pour les fonctionnalités
  bool _obscurePassword = true;
  bool _obscureConfPassword = true;
  String _selectedCountryCode = '+225';
  bool _isLoading = false;

  // Liste des indicatifs pays
  final List<Map<String, String>> countryCodes = [
    {'code': '+225', 'country': 'Côte d\'Ivoire'},
    {'code': '+33', 'country': 'France'},
    {'code': '+1', 'country': 'USA'},
    {'code': '+44', 'country': 'UK'},
    {'code': '+49', 'country': 'Allemagne'},
    {'code': '+237', 'country': 'Cameroun'},
    {'code': '+229', 'country': 'Bénin'},
    {'code': '+226', 'country': 'Burkina Faso'},
    {'code': '+223', 'country': 'Mali'},
    {'code': '+221', 'country': 'Sénégal'},
    {'code': '+228', 'country': 'Togo'},
    {'code': '+234', 'country': 'Nigeria'},
    {'code': '+233', 'country': 'Ghana'},
  ];

  // Fonction pour formater le numéro de téléphone
  String _formatPhoneNumber(String phone) {
    // Supprimer tous les caractères non numériques
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digits;
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Vérifier si l'email existe déjà
        final emailExists = await _databaseHelper.userExists(emailController.text.trim());
        if (emailExists) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cet email est déjà utilisé'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() { _isLoading = false; });
          return;
        }

        // Préparer les données utilisateur
        final fullName = nomPrenomController.text.trim();
        final names = fullName.split(' ');
        final nom = names.isNotEmpty ? names[0] : '';
        final prenom = names.length > 1 ? names.sublist(1).join(' ') : names.isNotEmpty ? names[0] : '';

        // Formater le numéro de téléphone
        final phoneDigits = _formatPhoneNumber(telController.text);
        final fullPhone = '$_selectedCountryCode$phoneDigits';

        final userData = {
          'nom': nom,
          'prenom': prenom,
          'email': emailController.text.trim(),
          'telephone': fullPhone,
          'password': passwordController.text,
        };

        // Insérer l'utilisateur dans la base de données
        final userId = await _databaseHelper.registerUser(userData);

        if (userId > 0) {
          if (!mounted) return;
          
          // Afficher le message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie ! Vous pouvez maintenant vous connecter.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Rediriger vers la page login après un court délai
          await Future.delayed(const Duration(seconds: 2));
          
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'inscription: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
        title: const Text(
          'Register',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Image de register en haut
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/register_image.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Champ Nom et Prénom fusionnés
                  TextFormField(
                    controller: nomPrenomController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom et prénom';
                      }
                      if (value.trim().split(' ').length < 2) {
                        return 'Veuillez entrer au moins un nom et un prénom';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Nom et Prénom(s)',
                      labelStyle: const TextStyle(color: Color(0xFF718096)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4299E1)),
                      ),
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF718096)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Champ Email
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!value.contains('@')) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Color(0xFF718096)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4299E1)),
                      ),
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF718096)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Champ Téléphone avec indicatif pays
                  Row(
                    children: [
                      // Dropdown pour l'indicatif pays
                      Container(
                        width: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            isExpanded: true,
                            items: countryCodes.map((country) {
                              return DropdownMenuItem<String>(
                                value: country['code'],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    '${country['code']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCountryCode = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Champ numéro de téléphone
                      Expanded(
                        child: TextFormField(
                          controller: telController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre numéro';
                            }
                            
                            // Supprimer les caractères non numériques pour la validation
                            final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                            
                            if (digits.isEmpty) {
                              return 'Le numéro doit contenir uniquement des chiffres';
                            }
                            
                            if (digits.length < 8) {
                              return 'Le numéro doit avoir au moins 8 chiffres';
                            }
                            
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Numéro de téléphone',
                            labelStyle: const TextStyle(color: Color(0xFF718096)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF4299E1)),
                            ),
                            hintText: 'Ex: 0102030405',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // Champ Password avec option voir/cacher
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Color(0xFF718096)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4299E1)),
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF718096)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF718096),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Champ Confirmation Password avec option voir/cacher
                  TextFormField(
                    controller: confPasswordController,
                    obscureText: _obscureConfPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Confirmer Password',
                      labelStyle: const TextStyle(color: Color(0xFF718096)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4299E1)),
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF718096)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfPassword ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF718096),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfPassword = !_obscureConfPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Boutons Login et Register côte à côte
                  Row(
                    children: [
                      // Bouton Login (à gauche)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Color(0xFF4299E1)),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4299E1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Bouton Register (à droite)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4299E1),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}