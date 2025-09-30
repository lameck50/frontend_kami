import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/user.dart';
import '../providers/admin_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchUsers();
    });
  }

  void _showUserDialog({User? user}) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: user?.name);
    final _emailController = TextEditingController(text: user?.email);
    final _passwordController = TextEditingController();
    String _selectedRole = user?.role ?? 'agent';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? 'Ajouter un utilisateur' : 'Modifier l\'utilisateur'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom complet'),
                    validator: (value) => value!.isEmpty ? 'Veuillez entrer un nom' : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value!.isEmpty ? 'Veuillez entrer un email' : null,
                  ),
                  if (user == null) // Only show password field for new users
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      obscureText: true,
                      validator: (value) => value!.isEmpty ? 'Veuillez entrer un mot de passe' : null,
                    ),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Rôle'),
                    items: ['admin', 'superviseur', 'agent'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedRole = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final provider = Provider.of<AdminProvider>(context, listen: false);
                  final userData = {
                    'name': _nameController.text,
                    'email': _emailController.text,
                    'role': _selectedRole,
                    if (user == null) 'password': _passwordController.text,
                  };

                  bool success = false;
                  if (user == null) {
                    success = await provider.createUser(userData);
                  } else {
                    success = await provider.updateUser(user.id, userData);
                  }

                  if (success && mounted) {
                    Navigator.of(context).pop();
                  } else {
                    // Optionally show an error within the dialog
                  }
                }
              },
              child: Text(user == null ? 'Ajouter' : 'Mettre à jour'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer l\'utilisateur ${user.name} ?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final provider = Provider.of<AdminProvider>(context, listen: false);
                final success = await provider.deleteUser(user.id);
                if (success && mounted) {
                  Navigator.of(context).pop();
                } else {
                  // Optionally show an error
                }
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(child: Text('Erreur: ${provider.error}'));
          }

          if (provider.users.isEmpty) {
            return const Center(child: Text('Aucun utilisateur trouvé.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchUsers(),
            child: ListView.builder(
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                final user = provider.users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text('${user.email} - ${user.role}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showUserDialog(user: user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Ajouter un utilisateur',
      ),
    );
  }
}
