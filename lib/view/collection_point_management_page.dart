import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/collection_point.dart';
import '../viewmodel/map_viewmodel.dart';

class CollectionPointManagementPage extends StatefulWidget {
  const CollectionPointManagementPage({super.key});

  @override
  State<CollectionPointManagementPage> createState() => _CollectionPointManagementPageState();
}

class _CollectionPointManagementPageState extends State<CollectionPointManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedItems = [];

  final List<String> _availableItems = [
    'Eletrônicos',
    'Baterias',
    'Pilhas',
    'Celulares',
    'Computadores',
    'Impressoras',
    'Outros',
  ];

  @override
  Widget build(BuildContext context) {
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text(point.name),
                  subtitle: Text(point.address),
                  trailing: Switch(
                    value: point.isActive,
                    onChanged: (value) => _togglePointStatus(viewModel, point),
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
                          ElevatedButton(
                            onPressed: () => _showEditDialog(context, viewModel, point),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00897B),
                            ),
                            child: const Text('Editar Ponto'),
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um nome';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Endereço'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um endereço';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Itens aceitos:'),
                Wrap(
                  spacing: 8,
                  children: _availableItems.map((item) => FilterChip(
                    label: Text(item),
                    selected: _selectedItems.contains(item),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedItems.add(item);
                        } else {
                          _selectedItems.remove(item);
                        }
                      });
                    },
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _addCollectionPoint(context);
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
    _addressController.text = point.address;
    _descriptionController.text = point.description ?? '';
    _selectedItems
      ..clear()
      ..addAll(point.acceptedItems);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Ponto de Coleta'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um nome';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Endereço'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um endereço';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Itens aceitos:'),
                Wrap(
                  spacing: 8,
                  children: _availableItems.map((item) => FilterChip(
                    label: Text(item),
                    selected: _selectedItems.contains(item),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedItems.add(item);
                        } else {
                          _selectedItems.remove(item);
                        }
                      });
                    },
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _updateCollectionPoint(context, viewModel, point);
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
    
    try {
      await viewModel.addPoint(
        _nameController.text,
        _addressController.text,
        _descriptionController.text,
        List<String>.from(_selectedItems),
        'current_user_id', // TODO: Pegar o ID do usuário logado
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
        address: _addressController.text,
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
    _addressController.clear();
    _descriptionController.clear();
    _selectedItems.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}