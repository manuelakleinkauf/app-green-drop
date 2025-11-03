import 'package:app/viewmodel/donation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController itemsController = TextEditingController();

  void registerDonation() async {
    if (_formKey.currentState!.validate()) {
      try {
        final email = emailController.text.trim();
        final items = int.tryParse(itemsController.text.trim()) ?? 0;

        final donationVM = Provider.of<DonationViewModel>(context, listen: false);

        await donationVM.registerDonation(email, items);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doação registrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        _formKey.currentState!.reset();
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar doação: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    itemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Doação'),
        backgroundColor: const Color(0xFF3CB371),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email do Doador',
                  prefixIcon: Icon(Icons.email, color: Color(0xFF3CB371)),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o email do doador';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: itemsController,
                decoration: const InputDecoration(
                  hintText: 'Quantidade de itens',
                  prefixIcon: Icon(Icons.add_box, color: Color(0xFF3CB371)),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a quantidade de itens';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Informe um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: registerDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3CB371),
                  ),
                  child: const Text(
                    'Registrar Doação',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
