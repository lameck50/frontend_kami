import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/auth_remote_data_source.dart'; // Pour ServerException
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import '../../../supervisor_dashboard/presentation/screens/supervisor_home_screen.dart';
import '../../../agent_dashboard/presentation/screens/agent_home_screen.dart';
import '../../../admin/presentation/screens/admin_home_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordObscured = true; // État pour la visibilité du mot de passe

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(_emailCtrl.text, _pwCtrl.text);

      if (mounted) {
        // Redirection basée sur le rôle
        final role = authProvider.user?['role'];
        if (role == 'superviseur') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SupervisorHomeScreen()));
        } else if (role == 'agent') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AgentHomeScreen()));
        } else if (role == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomeScreen()));
        } else {
          // Gérer le cas où le rôle n'est pas défini ou inconnu
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(backgroundColor: Colors.orange, content: Text('Rôle utilisateur non reconnu.')),
          );
        }
      }
    } catch (error) {
      final errorMessage = error is ServerException
          ? error.message
          : "Une erreur inattendue est survenue.";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KamiGeoloc', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Bienvenue",
                      style: Theme.of(c).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Connectez-vous à votre compte",
                      style: Theme.of(c).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pwCtrl,
                      obscureText: _isPasswordObscured, // Utilise la variable d'état
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordObscured = !_isPasswordObscured;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _login,
                            child: const Text("SE CONNECTER", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text("Vous n'avez pas de compte ?"),
                        TextButton(
                          onPressed: _isLoading ? null : () => Navigator.push(c, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          child: const Text("Créer un compte"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
