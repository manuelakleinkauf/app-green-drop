import 'package:app/model/user.dart';
import 'package:app/model/collection_point.dart';
import 'package:app/model/activity.dart';
import 'package:app/viewmodel/donation_view_model.dart';
import 'package:app/viewmodel/map_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/item_quantity_selector.dart';

class DonationPage extends StatefulWidget {
  final UserModel user;

  const DonationPage({super.key, required this.user});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _formKey = GlobalKey<FormState>();
  CollectionPoint? _selectedPoint;
  final Map<String, int> _selectedItems = {};
  bool _isSubmitting = false;

  void registerDonation() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPoint == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione um ponto de coleta'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, adicione pelo menos um item'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final invalidItems = _selectedItems.keys
          .where((item) => !_selectedPoint!.acceptedItems.contains(item))
          .toList();

      if (invalidItems.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Este ponto não aceita: ${invalidItems.join(', ')}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        final donationVM =
            Provider.of<DonationViewModel>(context, listen: false);

        await donationVM.registerDonation(
          userId: widget.user.uid,
          collectionPointId: _selectedPoint!.id,
          collectionPointName: _selectedPoint!.name,
          itemDetails: _selectedItems,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doação registrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _selectedPoint = null;
          _selectedItems.clear();
        });
        _formKey.currentState!.reset();
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar doação: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canRegister = widget.user.canRegisterDonation;

    if (!canRegister) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acesso Negado'),
          backgroundColor: const Color(0xFF3CB371),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Você não tem permissão para registrar doações.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Apenas Doadores e Administradores podem registrar doações.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(
        title: const Text('Registrar Doação'),
        backgroundColor: const Color(0xFF3CB371),
      ),
      body: SafeArea( 
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 20, 
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCollectionPointSelector(),
                const SizedBox(height: 24),
                if (_selectedPoint != null) ...[
                  _buildItemSelector(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Histórico de Doações',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildDonationHistory(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionPointSelector() {
    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, child) {
        final activePoints =
            mapViewModel.points.where((p) => p.isActive).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ponto de Coleta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (activePoints.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Nenhum ponto de coleta ativo disponível no momento.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              DropdownButtonFormField<CollectionPoint>(
                value: _selectedPoint,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon:
                      const Icon(Icons.location_on, color: Color(0xFF3CB371)),
                ),
                hint: const Text('Selecione o ponto de coleta'),
                isExpanded: true,
                items: activePoints.map((point) {
                  return DropdownMenuItem(
                    value: point,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        '${point.name} - ${point.address}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPoint = value;
                    _selectedItems.clear();
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione um ponto de coleta' : null,
              ),
          ],
        );
      },
    );
  }

  Widget _buildItemSelector() {
    return ItemQuantitySelector(
      availableItems: _selectedPoint!.acceptedItems,
      selectedItems: _selectedItems,
      onItemsChanged: (items) {
        setState(() {
          _selectedItems.clear();
          _selectedItems.addAll(items);
        });
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : registerDonation,
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle, color: Colors.white),
        label: Text(
          _isSubmitting ? 'Registrando...' : 'Registrar Doação',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3CB371),
          disabledBackgroundColor: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDonationHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activities')
          .where('userId', isEqualTo: widget.user.uid)
          .where('type', isEqualTo: 'donation')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Nenhuma doação registrada ainda.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final activities = snapshot.data!.docs
            .map((doc) => Activity.fromFirestore(doc))
            .toList();
        activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return Column(
          children: activities.map((activity) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF3CB371),
                  child: Text(
                    activity.totalItems.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  activity.collectionPointName ?? activity.location,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${activity.totalItems} ${activity.totalItems == 1 ? 'item' : 'itens'} • ${activity.points} pontos',
                ),
                trailing: Text(
                  _formatDate(activity.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (activity.itemDetails != null &&
                            activity.itemDetails!.isNotEmpty) ...[
                          const Text(
                            'Detalhes da doação:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ...activity.itemDetails!.entries.map((entry) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('• ${entry.key}'),
                                  Text(
                                    '${entry.value}x',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const Divider(height: 24),
                        ],
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Local:'),
                            Flexible(
                              child: Text(
                                activity.location,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Pontos ganhos:'),
                            Text(
                              '+${activity.points}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3CB371),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Hoje';
    if (difference.inDays == 1) return 'Ontem';
    if (difference.inDays < 7) return '${difference.inDays} dias atrás';

    return '${date.day}/${date.month}/${date.year}';
  }
}
