import 'package:app/viewmodel/reward_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RewardHistoryPage extends StatelessWidget {
  final String userId;

  const RewardHistoryPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RewardViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Histórico de recompensas")),
      body: StreamBuilder(
        stream: viewModel.rewardHistory(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data!;

          if (history.isEmpty) {
            return const Center(child: Text("Nenhum resgate ainda."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];

              return Card(
                child: ListTile(
                  leading: item['imageUrl'] != null
                      ? Image.network(item['imageUrl'], width: 50)
                      : const Icon(Icons.card_giftcard),
                  title: Text(item['title']),
                  subtitle: Text("Pontos gastos: ${item['pointsSpent']}"),
                  trailing: Text(
                    (item['claimedAt'] as Timestamp)
                        .toDate()
                        .toLocal()
                        .toString()
                        .substring(0, 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
