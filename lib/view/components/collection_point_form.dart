import 'package:flutter/material.dart';

class CollectionPointForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController streetController;
  final TextEditingController numberController;
  final TextEditingController neighborhoodController;
  final TextEditingController cityController;
  final TextEditingController descriptionController;
  final List<String> selectedItems;
  final VoidCallback onSelectedItemsChanged;

  const CollectionPointForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.streetController,
    required this.numberController,
    required this.neighborhoodController,
    required this.cityController,
    required this.descriptionController,
    required this.selectedItems,
    required this.onSelectedItemsChanged,
  });

  @override
  State<CollectionPointForm> createState() => _CollectionPointFormState();
}

class _CollectionPointFormState extends State<CollectionPointForm> {
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
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.nameController,
            decoration: InputDecoration(
              labelText: 'Nome do Ponto',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o nome do ponto';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.streetController,
            decoration: InputDecoration(
              labelText: 'Rua',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira a rua';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.numberController,
            decoration: InputDecoration(
              labelText: 'Número',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o número';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.neighborhoodController,
            decoration: InputDecoration(
              labelText: 'Bairro',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o bairro';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.cityController,
            decoration: InputDecoration(
              labelText: 'Cidade',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira a cidade';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.descriptionController,
            decoration: InputDecoration(
              labelText: 'Descrição (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          const Text(
            'Itens aceitos:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableItems.map((item) {
              return FilterChip(
                label: Text(item),
                selected: widget.selectedItems.contains(item),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      widget.selectedItems.add(item);
                    } else {
                      widget.selectedItems.remove(item);
                    }
                    widget.onSelectedItemsChanged();
                  });
                },
                selectedColor: const Color(0xFF00897B).withOpacity(0.3),
                checkmarkColor: const Color(0xFF00897B),
              );
            }).toList(),
          ),
          if (widget.selectedItems.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Selecione pelo menos um item',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String getFullAddress() {
    return "${widget.streetController.text}, ${widget.numberController.text}, ${widget.neighborhoodController.text}, ${widget.cityController.text}";
  }
}
