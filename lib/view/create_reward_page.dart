import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/reward_viewmodel.dart';

class CreateRewardPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const CreateRewardPage({super.key, required this.user});

  @override
  State<CreateRewardPage> createState() => _CreateRewardPageState();
}

class _CreateRewardPageState extends State<CreateRewardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // Bloqueia acesso se nao for volunteer
    if (widget.user["accessProfile"] != "volunteer") {
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Acesso negado")),
        );
        Navigator.pop(context);
      });
    }
  }

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
