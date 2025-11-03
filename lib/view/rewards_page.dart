import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/reward.dart';
import '../viewmodel/reward_viewmodel.dart';

class RewardsPage extends StatelessWidget {
  final String userId;

  const RewardsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Recompensas'),
        backgroundColor: const Color(0xFF00897B),
      ),
      body: Consumer<RewardViewModel>(
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
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              return _buildRewardCard(context, reward, viewModel);
            },
          );
        },
      ),
    );
  }

  Widget _buildRewardCard(
    BuildContext context,
    Reward reward,
    RewardViewModel viewModel,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem da recompensa
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const Spacer(),
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
                      onPressed: () => _claimReward(context, reward, viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Resgatar'),
                    ),
                  ),
                ],
              ),
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