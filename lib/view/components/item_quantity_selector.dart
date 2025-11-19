import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ItemQuantitySelector extends StatefulWidget {
  final List<String> availableItems;
  final Map<String, int> selectedItems;
  final Function(Map<String, int>) onItemsChanged;

  const ItemQuantitySelector({
    super.key,
    required this.availableItems,
    required this.selectedItems,
    required this.onItemsChanged,
  });

  @override
  State<ItemQuantitySelector> createState() => _ItemQuantitySelectorState();
}

class _ItemQuantitySelectorState extends State<ItemQuantitySelector> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Inicializa controllers para cada item disponível
    for (var item in widget.availableItems) {
      final currentQty = widget.selectedItems[item] ?? 0;
      _controllers[item] = TextEditingController(
        text: currentQty > 0 ? currentQty.toString() : '',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateQuantity(String item, String value) {
    final quantity = int.tryParse(value) ?? 0;
    final updatedItems = Map<String, int>.from(widget.selectedItems);
    
    if (quantity > 0) {
      updatedItems[item] = quantity;
    } else {
      updatedItems.remove(item);
    }
    
    widget.onItemsChanged(updatedItems);
  }

  void _incrementQuantity(String item) {
    final currentQty = widget.selectedItems[item] ?? 0;
    final newQty = currentQty + 1;
    _controllers[item]!.text = newQty.toString();
    _updateQuantity(item, newQty.toString());
  }

  void _decrementQuantity(String item) {
    final currentQty = widget.selectedItems[item] ?? 0;
    if (currentQty > 0) {
      final newQty = currentQty - 1;
      _controllers[item]!.text = newQty > 0 ? newQty.toString() : '';
      _updateQuantity(item, newQty.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantidade por tipo de item:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.availableItems.map((item) {
          final quantity = widget.selectedItems[item] ?? 0;
          final isSelected = quantity > 0;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: isSelected ? 2 : 0,
            color: isSelected ? const Color(0xFF00897B).withOpacity(0.05) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _decrementQuantity(item),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: quantity > 0 ? const Color(0xFF00897B) : Colors.grey,
                    iconSize: 28,
                  ),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _controllers[item],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) => _updateQuantity(item, value),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _incrementQuantity(item),
                    icon: const Icon(Icons.add_circle_outline),
                    color: const Color(0xFF00897B),
                    iconSize: 28,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00897B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total de itens:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.selectedItems.values.fold<int>(0, (sum, qty) => sum + qty).toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00897B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
