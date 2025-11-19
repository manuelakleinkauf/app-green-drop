import 'package:app/model/user.dart';
import 'package:app/viewmodel/donation_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DonationPage extends StatefulWidget {
  final UserModel user;

  const DonationPage({super.key, required this.user});

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

        final donationVM =
            Provider.of<DonationViewModel>(context, listen: false);

        await donationVM.registerDonation(email, items);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doacao registrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        _formKey.currentState!.reset();
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar doacao: ${e.toString()}'),
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

  Widget buildDonationForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              hintText: 'Email do doador',
              prefixIcon: Icon(Icons.email, color: Color(0xFF3CB371)),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe o email do doador';
              }
              if (!value.contains('@')) {
                return 'Email invalido';
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
                return 'Informe um numero valido';
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
                'Registrar Doacao',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserDonations() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('activities')
          .where('userId', isEqualTo: widget.user.uid)
          .where('type', isEqualTo: 'donation')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma doacao encontrada.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final d = docs[index].data();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(d['description'] ?? 'Sem descricao'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Local: ${d['location']}"),
                    Text("Pontos ganhos: ${d['points']}"),
                    Text("Data: ${d['timestamp'].toDate()}"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVolunteer = widget.user.accessProfile == 'volunteer';
    final isDonor = widget.user.accessProfile == 'donor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doacoes'),
        backgroundColor: const Color(0xFF3CB371),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isVolunteer
            ? buildDonationForm()
            : isDonor
                ? buildUserDonations()
                : const Center(
                    child: Text(
                      'Perfil nao autorizado.',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
      ),
    );
  }
}
