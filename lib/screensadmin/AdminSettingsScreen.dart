import 'dart:async';
import 'package:florapp/screensadmin/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool notificationsEnabled = true;

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _showChangePasswordDialog() {
    final TextEditingController _currentPasswordController = TextEditingController();
    final TextEditingController _newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Cambiar Contraseña'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              if (mounted) Navigator.pop(context);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAC0A0A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Actualizar'),
            onPressed: () async {
              final currentPassword = _currentPasswordController.text.trim();
              final newPassword = _newPasswordController.text.trim();

              if (newPassword.length < 6) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('La nueva contraseña debe tener al menos 6 caracteres')),
                  );
                }
                return;
              }

              if (mounted) Navigator.pop(context); // Cierra el diálogo

              try {
                final user = FirebaseAuth.instance.currentUser;
                final email = user?.email;

                if (user != null && email != null) {
                  final cred = EmailAuthProvider.credential(
                    email: email,
                    password: currentPassword,
                  );

                  await user.reauthenticateWithCredential(cred).timeout(const Duration(seconds: 10));
                  await user.updatePassword(newPassword).timeout(const Duration(seconds: 10));

                  if (mounted) Navigator.pop(context); // Cierra loading
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contraseña actualizada exitosamente')),
                    );
                  }
                }
              } catch (e) {

                String errorMessage = 'Ocurrió un error. Intenta nuevamente';

                if (e is TimeoutException) {
                  errorMessage = 'Tiempo de espera excedido. Verifica tu conexión.';
                } else if (e is FirebaseAuthException) {
                  if (e.code == 'wrong-password') {
                    errorMessage = 'La contraseña actual es incorrecta';
                  } else if (e.code == 'too-many-requests') {
                    errorMessage = 'Demasiados intentos. Intenta más tarde.';
                  } else {
                    errorMessage = e.message ?? errorMessage;
                  }
                }

                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: Text(errorMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color(0xFFAC0A0A),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Cambiar contraseña'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showChangePasswordDialog,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            trailing: const Text('Español'),
            onTap: () {},
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('Notificaciones'),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
}
