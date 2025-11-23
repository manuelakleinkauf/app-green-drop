import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/collection_point.dart';
import '../viewmodel/map_viewmodel.dart';
import '../viewmodel/current_user_provider.dart';
import 'components/collection_point_form.dart';
import 'confirm_donations_page.dart';

class CollectionPointManagementPage extends StatefulWidget {
  const CollectionPointManagementPage({super.key});

  @override
  State<CollectionPointManagementPage> createState() => _CollectionPointManagementPageState();
}

class _CollectionPointManagementPageState extends State<CollectionPointManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedItems = [];

  String getFullAddress() {
    return "${_streetController.text}, ${_numberController.text}, ${_neighborhoodController.text}, ${_cityController.text}";
  }

  void _parseAddress(String address) {
    // Tenta separar o endereço nas suas partes
    final parts = address.split(',').map((e) => e.trim()).toList();
    
    if (parts.length >= 4) {
      _streetController.text = parts[0];
      _numberController.text = parts[1];
      _neighborhoodController.text = parts[2];
      _cityController.text = parts.sublist(3).join(', ');
    } else {
      // Se não conseguir separar, coloca tudo na rua
      _streetController.text = address;
      _numberController.text = '';
      _neighborhoodController.text = '';
      _cityController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<CurrentUserProvider>(context);
    
    // Debug: Imprimir informações do usuário
    print("=== DEBUG COLLECTION POINT MANAGEMENT ===");
    print("User UID: ${userProvider.currentUser?.uid}");
    print("User Role: ${userProvider.currentUser?.role}");
    print("Can view management: ${userProvider.canViewCollectionPointManagement}");

    // Verifica se o usuário tem permissão para acessar esta página
    if (!userProvider.canViewCollectionPointManagement) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acesso Negado'),
          backgroundColor: const Color(0xFF00897B),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Você não tem permissão para acessar esta página.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Apenas Voluntários e Administradores podem gerenciar pontos de coleta.',
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
      appBar: AppBar(
        title: const Text('Gestão de Pontos de Coleta'),
        backgroundColor: const Color(0xFF00897B),
      ),
      body: Consumer<MapViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: viewModel.points.length,
            itemBuilder: (context, index) {
              final point = viewModel.points[index];
              final canEdit = userProvider.canEditCollectionPoint(point.createdBy);
              
              // Debug: Imprimir informações do ponto
              print("Ponto ${index + 1}: ${point.name}");
              print("  - ID: ${point.id}");
              print("  - CreatedBy: ${point.createdBy}");
              print("  - Can Edit: $canEdit");
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text(point.name),
                  subtitle: Text(point.address),
                  trailing: canEdit
                      ? Switch(
                          value: point.isActive,
                          onChanged: (value) => _togglePointStatus(viewModel, point),
                        )
                      : Chip(
                          label: Text(
                            point.isActive ? 'Ativo' : 'Inativo',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: point.isActive ? Colors.green[100] : Colors.red[100],
                        ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Descrição: ${point.description ?? "Sem descrição"}'),
                          const SizedBox(height: 8),
                          const Text('Itens aceitos:'),
                          Wrap(
                            spacing: 8,
                            children: point.acceptedItems.map((item) => Chip(
                              label: Text(item),
                            )).toList(),
                          ),
                          const SizedBox(height: 16),
                          if (canEdit)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _showEditDialog(context, viewModel, point),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Editar Ponto'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00897B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('activities')
                                      .where('collectionPointId', isEqualTo: point.id)
                                      .where('status', isEqualTo: 'pending')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    final pendingCount = snapshot.data?.docs.length ?? 0;
                                    
                                    return ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ConfirmDonationsPage(
                                              collectionPointId: point.id,
                                              collectionPointName: point.name,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Badge(
                                        label: Text('$pendingCount'),
                                        isLabelVisible: pendingCount > 0,
                                        child: const Icon(Icons.check_circle_outline),
                                      ),
                                      label: Text('Confirmar Doações${pendingCount > 0 ? ' ($pendingCount)' : ''}'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: pendingCount > 0 ? Colors.orange : Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            )
                          else
                            const Text(
                              'Você não pode editar este ponto',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: const Color(0xFF00897B),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    _clearForm();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Ponto de Coleta'),
        content: SingleChildScrollView(
          child: CollectionPointForm(
            formKey: _formKey,
            nameController: _nameController,
            streetController: _streetController,
            numberController: _numberController,
            neighborhoodController: _neighborhoodController,
            cityController: _cityController,
            descriptionController: _descriptionController,
            selectedItems: _selectedItems,
            onSelectedItemsChanged: () {
              setState(() {});
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate() && _selectedItems.isNotEmpty) {
                _addCollectionPoint(context);
              } else if (_selectedItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selecione pelo menos um item aceito')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
            ),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, MapViewModel viewModel, CollectionPoint point) async {
    _nameController.text = point.name;
    _parseAddress(point.address);
    _descriptionController.text = point.description ?? '';
    _selectedItems
      ..clear()
      ..addAll(point.acceptedItems);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Ponto de Coleta'),
        content: SingleChildScrollView(
          child: CollectionPointForm(
            formKey: _formKey,
            nameController: _nameController,
            streetController: _streetController,
            numberController: _numberController,
            neighborhoodController: _neighborhoodController,
            cityController: _cityController,
            descriptionController: _descriptionController,
            selectedItems: _selectedItems,
            onSelectedItemsChanged: () {
              setState(() {});
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate() && _selectedItems.isNotEmpty) {
                _updateCollectionPoint(context, viewModel, point);
              } else if (_selectedItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selecione pelo menos um item aceito')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCollectionPoint(BuildContext context) async {
    final viewModel = Provider.of<MapViewModel>(context, listen: false);
    final userProvider = Provider.of<CurrentUserProvider>(context, listen: false);
    
    try {
      await viewModel.addPoint(
        _nameController.text,
        getFullAddress(),
        _descriptionController.text,
        List<String>.from(_selectedItems),
        userProvider.currentUser!.uid,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ponto de coleta adicionado com sucesso!')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar ponto: $e')),
      );
    }
  }

  Future<void> _updateCollectionPoint(BuildContext context, MapViewModel viewModel, CollectionPoint point) async {
    try {
      final updatedPoint = point.copyWith(
        name: _nameController.text,
        address: getFullAddress(),
        description: _descriptionController.text,
        acceptedItems: List<String>.from(_selectedItems),
      );

      await viewModel.updatePoint(updatedPoint);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ponto de coleta atualizado com sucesso!')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar ponto: $e')),
      );
    }
  }

  Future<void> _togglePointStatus(MapViewModel viewModel, CollectionPoint point) async {
    try {
      await viewModel.togglePointStatus(point.id, !point.isActive);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            point.isActive
                ? 'Ponto de coleta desativado!'
                : 'Ponto de coleta ativado!',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao alterar status do ponto: $e')),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _streetController.clear();
    _numberController.clear();
    _neighborhoodController.clear();
    _cityController.clear();
    _descriptionController.clear();
    _selectedItems.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}