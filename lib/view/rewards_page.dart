import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/reward.dart';
import '../viewmodel/reward_viewmodel.dart';
import 'create_reward_page.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/reward.dart';
import '../viewmodel/reward_viewmodel.dart';
import 'create_reward_page.dart';
import 'history_reward_page.dart';

class RewardsPage extends StatelessWidget {
  final String userId;
  final String accessProfile;

  RewardsPage({
    super.key,
    required this.userId,
    required this.accessProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Recompensas'),
        backgroundColor: const Color(0xFF00897B),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Recompensas resgatadas",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RewardHistoryPage(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData =
              userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
          final int currentPoints = userData['points'] ?? 0;

          return Consumer<RewardViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final rewards = viewModel.availableRewards;

              if (rewards.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma recompensa disponível no momento',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.60,
                  crossAxisSpacing: 16,
                ),
                itemCount: rewards.length,
                itemBuilder: (context, index) {
                  final reward = rewards[index];
                  return _buildRewardCard(
                    context,
                    reward,
                    viewModel,
                    currentPoints,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: accessProfile == "volunteer"
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF00897B),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateRewardPage(
                      user: {
                        "accessProfile": accessProfile,
                        "userId": userId,
                      },
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildRewardCard(
    BuildContext context,
    Reward reward,
    RewardViewModel viewModel,
    int currentPoints,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEM DO CARTÃO
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              image: reward.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(reward.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: const Color(0xFF00897B).withOpacity(0.1),
            ),
            child: reward.imageUrl == null
                ? const Center(
                    child: Icon(
                      Icons.card_giftcard,
                      size: 48,
                      color: Color(0xFF00897B),
                    ),
                  )
                : null,
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reward.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  reward.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${reward.pointsCost} pontos',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: currentPoints >= reward.pointsCost
                        ? () => _claimReward(context, reward, viewModel)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPoints >= reward.pointsCost
                          ? const Color(0xFF00897B)
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      currentPoints >= reward.pointsCost
                          ? 'Resgatar'
                          : 'Pontos insuficientes',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _claimReward(
    BuildContext context,
    Reward reward,
    RewardViewModel viewModel,
  ) async {
    try {
      await viewModel.claimReward(reward.id, userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recompensa resgatada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
