import 'package:flutter/material.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/providers/supervisor_provider.dart';
import 'package:provider/provider.dart';

class CreateMissionScreen extends StatefulWidget {
  const CreateMissionScreen({super.key});

  @override
  State<CreateMissionScreen> createState() => _CreateMissionScreenState();
}

class _CreateMissionScreenState extends State<CreateMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedAgentId;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final provider = Provider.of<SupervisorProvider>(context, listen: false);
      final success = await provider.createMission(
        _titleController.text,
        _descriptionController.text,
        _selectedAgentId!,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(); // Revenir à l\'écran des missions
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.missionsError),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accéder au provider pour la liste des agents
    final agents = Provider.of<SupervisorProvider>(context, listen: false).agents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une mission'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de la mission',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAgentId,
                decoration: const InputDecoration(
                  labelText: 'Assigner à l\'agent',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Sélectionner un agent'),
                items: agents.map<DropdownMenuItem<String>>((agent) {
                  return DropdownMenuItem<String>(
                    value: agent['id'],
                    child: Text(agent['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAgentId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez assigner la mission à un agent.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('CRÉER LA MISSION'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
