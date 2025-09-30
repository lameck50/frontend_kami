import 'package:flutter/material.dart';
import '../providers/supervisor_provider.dart';
import '../screens/agent_detail_screen.dart';

class AgentSearchDelegate extends SearchDelegate {
  final SupervisorProvider supervisorProvider;

  AgentSearchDelegate({required this.supervisorProvider});

  @override
  String get searchFieldLabel => 'Rechercher un agent...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // Quand on quitte la recherche, on réinitialise le filtre
    supervisorProvider.searchAgents('');
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    supervisorProvider.searchAgents(query);
    final agents = supervisorProvider.agents;

    if (agents.isEmpty) {
      return const Center(child: Text('Aucun agent trouvé.'));
    }
    return ListView.builder(
      itemCount: agents.length,
      itemBuilder: (context, index) {
        final agent = agents[index];
        return ListTile(
          title: Text(agent['name']),
          onTap: () {
            supervisorProvider.searchAgents(''); // Réinitialise la recherche
            close(context, null); // Ferme la recherche
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AgentDetailScreen(agent: agent),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    supervisorProvider.searchAgents(query);
    final agents = supervisorProvider.agents;

    return ListView.builder(
      itemCount: agents.length,
      itemBuilder: (context, index) {
        final agent = agents[index];
        return ListTile(
          title: Text(agent['name']),
          onTap: () {
            query = agent['name'];
            showResults(context);
          },
        );
      },
    );
  }
}