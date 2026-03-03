import 'package:florapp/screens/direcciones_screen.dart';
import 'package:florapp/screensadmin/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatelessWidget {
  void _onLogoutPressed(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Cierra sesión en Firebase
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ), // Tu pantalla LoginScreen
      (route) => false, // Borra todo el stack para que no puedas regresar
    );
  }

  String countryCodeToEmoji(String countryCode) {
    final int base = 0x1F1E6 - 'A'.codeUnitAt(0);
    final firstChar = countryCode.codeUnitAt(0) + base;
    final secondChar = countryCode.codeUnitAt(1) + base;
    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  Widget _buildOptionButton({
    required String title,
    String? trailingText,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing:
              trailingWidget ??
              (trailingText != null
                  ? Text(
                      trailingText,
                      style: const TextStyle(color: Colors.grey),
                    )
                  : null),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          dense: true,
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFA50302),
        title: const Text(
          'Ajustes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // texto blanco
          ),
        ),
        leading: const BackButton(
          color: Colors.white, // flecha blanca
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOptionButton(
            title: 'Perfil',
            onTap: () {
              /* Navegar a perfil */
            },
          ),

          _buildOptionButton(
            title: 'Direcciones de entrega',
            onTap: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DireccionesScreen(userId: user.uid),
                  ),
                );
              } else {
                // Navega a LoginScreen en vez de solo mostrar un mensaje
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LoginScreen(), // <-- Cambia por el nombre de tu pantalla de login
                  ),
                );
              }
            },
          ),

          _buildOptionButton(
            title: 'Idioma',
            trailingText: 'Español',
            onTap: () {
              /* Cambiar idioma */
            },
          ),

          _buildOptionButton(title: 'Opciones de notificaciones', onTap: () {}),
          _buildOptionButton(title: 'Historial', onTap: () {}),
          _buildOptionButton(title: 'Valorar FlorApp', onTap: () {}),
          _buildOptionButton(title: 'Política de privacidad', onTap: () {}),
          _buildOptionButton(title: 'Información legal', onTap: () {}),

          _buildOptionButton(
            title: 'Versión',
            trailingText: '0.0.1',
            onTap: null,
          ),

          _buildOptionButton(
            title: 'Eliminar cuenta',
            onTap: () async {
              User? user = FirebaseAuth.instance.currentUser;

              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No hay usuario autenticado')),
                );
                return;
              }

              try {
                // Borra los datos en Firestore
                await FirebaseFirestore.instance
                    .collection('Usuarios')
                    .doc(user.uid)
                    .delete();

                // Luego elimina la cuenta de autenticación
                await user.delete();

                // Cierra sesión
                await FirebaseAuth.instance.signOut();

                // Navega a login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cuenta y datos eliminados con éxito'),
                  ),
                );
              } on FirebaseAuthException catch (e) {
                if (e.code == 'requires-recent-login') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por seguridad, vuelve a iniciar sesión para eliminar tu cuenta.',
                      ),
                    ),
                  );
                  // Aquí reautenticar usuario para proceder (opcional)
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar cuenta: ${e.message}'),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
              }
            },
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA50302),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () => _onLogoutPressed(context), // Llama la función
                child: const Text(
                  'CERRAR SESIÓN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
