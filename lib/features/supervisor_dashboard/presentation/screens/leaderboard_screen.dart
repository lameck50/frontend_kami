import 'package:flutter/material.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/providers/supervisor_provider.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupervisorProvider>(context, listen: false).fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SupervisorProvider>(
        builder: (context, provider, child) {
          if (provider.isFetchingLeaderboard) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.leaderboardError.isNotEmpty) {
            return Center(child: Text('Erreur: ${provider.leaderboardError}'));
          }

          if (provider.leaderboard.isEmpty) {
            return const Center(child: Text('Aucun agent dans le classement.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchLeaderboard(),
            child: ListView.builder(
              itemCount: provider.leaderboard.length,
              itemBuilder: (context, index) {
                final agent = provider.leaderboard[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(agent['name']),
                  trailing: Text('${agent['points']} points'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
