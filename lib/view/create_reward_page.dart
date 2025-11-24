import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/reward_viewmodel.dart';
import '../viewmodel/current_user_provider.dart';

class CreateRewardPage extends StatelessWidget {
  const CreateRewardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<CurrentUserProvider>(context);

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
                  'Apenas Voluntários e Administradores podem cadastrar recompensas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const _CreateRewardForm();
  }
}

class _CreateRewardForm extends StatefulWidget {
  const _CreateRewardForm();

  @override
  State<_CreateRewardForm> createState() => _CreateRewardFormState();
}

class _CreateRewardFormState extends State<_CreateRewardForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final rewardVM = Provider.of<RewardViewModel>(context, listen: false);

    setState(() => _loading = true);

    try {
      await rewardVM.addReward(
        _titleController.text,
        _descriptionController.text,
        int.parse(_pointsController.text),
        int.parse(_quantityController.text),
        null, // imageUrl opcional
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recompensa cadastrada")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastrar Recompensa"),
        backgroundColor: const Color(0xFF00897B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Titulo",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Informe o titulo" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Descricao",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Informe a descricao" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pointsController,
                decoration: const InputDecoration(
                  labelText: "Custo em pontos",
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Informe os pontos";
                  if (int.tryParse(v) == null) return "Digite um numero valido";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: "Quantidade",
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Informe a quantidade";
                  if (int.tryParse(v) == null) return "Digite um numero valido";
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Salvar",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
