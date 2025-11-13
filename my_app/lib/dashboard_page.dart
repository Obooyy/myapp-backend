import 'package:flutter/material.dart';
import 'main.dart';
import 'categorie_page.dart';
import 'produits_page.dart';

class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  
  const DashboardPage({super.key, required this.userData});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
          content: const Text('Voulez-vous vous déconnecter ?', style: TextStyle(color: Color(0xFF718096))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF718096)),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomePage()),
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Oui'),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userName = userData['prenom'] ?? 'Utilisateur';
    final String userLastName = userData['nom'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Dash', style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/dashboard.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4299E1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF4299E1).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('Welcome', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                  const SizedBox(height: 5),
                  Text('$userName $userLastName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF4299E1))),
                  const SizedBox(height: 5),
                  Text(userData['email'] ?? '', style: const TextStyle(fontSize: 14, color: Color(0xFF718096))),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Column(
                children: [
                  Text('Dash', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4299E1))),
                  SizedBox(height: 10),
                  Text('Delivery Service', style: TextStyle(fontSize: 18, color: Color(0xFF718096))),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriePage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4299E1),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Catégorie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProduitsPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFF4299E1)),
                      ),
                    ),
                    child: const Text('Produits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4299E1))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text('Se déconnecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}