import 'package:flutter/material.dart';

void main() {
  runApp(const GreenDropApp());
}

class GreenDropApp extends StatelessWidget {
  const GreenDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenDrop',
      theme: ThemeData(primaryColor: const Color(0xFF57CC99)),
      home: const NewsPage(),
    );
  }
}

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  final List<Map<String, String>> cards = const [
    {
      'title': 'O que cada divisão de lixo eletrônico significa?',
      'content': '''
      Linha Azul: Pequenos eletrodomésticos e ferramentas eléticas. Exemplo: Parafusadeira, furadeira, liquidificador, batedeira, dentre outros.
      Linha Verde: Equipamentos de informática e telefonia. Exemplo: Computador, notebook, impressora, telefone, celulares, dentre outros.
      Linha Marrom: Equipamentos de áudios e vídeos. Exemplo: Som, TV, vídeo game, home theater, dentre outros.
      Linha Branca: Grandes eletrodomésticos. Exemplos: fogão, máquinas de lavar, microondas, dentre outros.
      ''',
      'image': 'assets/images/lixo_eletronico.png',
    },
    {
      'title': 'Como posso incentivar outras pessoas?',
      'content': '''
          1. Dê o exemplo: Separe corretamente seus resíduos em casa e mostre como é simples contribuir com o meio ambiente.

          2. Compartilhe conhecimento: Ensine familiares e amigos sobre os tipos de materiais recicláveis e como fazer o descarte correto.

          3. Use as redes sociais: Poste dicas e informações úteis sobre reciclagem, pontos de coleta e impacto ambiental.

          4. Envolva crianças e jovens: Ensinar desde cedo ajuda a formar adultos mais conscientes e responsáveis com o planeta.

          5. Crie momentos educativos: Promova rodas de conversa, oficinas ou até dinâmicas em escolas e comunidades sobre sustentabilidade.

          6. Reforce os benefícios: Reciclar ajuda a reduzir a poluição, economiza recursos naturais e melhora a qualidade de vida de todos.

          Cada pequena atitude conta — juntos, podemos transformar hábitos e cuidar melhor do nosso planeta!
          ''',
    },
    {
      'title': 'Aprenda como descartar corretamente',
      'content': '''
          1. Faça um backup dos seus dados: Antes de descartar celulares, notebooks ou câmeras, salve seus arquivos importantes em um local seguro (como nuvem ou HD externo).

          2. Remova cartões e chips: Retire o chip e o cartão de memória de celulares, câmeras e tablets para evitar que dados pessoais fiquem acessíveis.

          3. Restaure para as configurações de fábrica: Limpe todos os dados do dispositivo, especialmente em celulares e computadores.

          4. Desmonte com cuidado (se necessário): Em equipamentos muito antigos, retire pilhas ou baterias, pois podem conter materiais tóxicos e devem ser descartadas separadamente.

          5. Separe por tipo de eletrônico: Agrupe os dispositivos conforme as categorias — como linha verde (informática), linha marrom (áudio e vídeo), linha azul (ferramentas), e linha branca (eletrodomésticos).

          6. Leve até um ponto de coleta autorizado: Nunca jogue lixo eletrônico no lixo comum. Utilize ecopontos ou campanhas de coleta específicas da sua cidade.

          7. Nunca queime ou quebre os aparelhos: Além de perigoso, isso pode liberar substâncias tóxicas no ambiente.

          Descarte consciente evita danos à natureza e protege seus dados pessoais. Faça sua parte!
          ''',
    },
    {
      'title': 'Entenda a importância da reciclagem dos materiais',
      'content': '''
        1. Redução da poluição: Materiais eletrônicos descartados de forma incorreta liberam substâncias tóxicas no solo, na água e no ar, contaminando o meio ambiente.

        2. Preservação de recursos naturais: A reciclagem permite reaproveitar metais, plásticos e outros componentes, reduzindo a necessidade de extração de novos recursos da natureza.

        3. Economia de energia: Reciclar materiais consome menos energia do que produzir novos a partir de matéria-prima virgem.

        4. Geração de empregos: A cadeia da reciclagem movimenta a economia e cria oportunidades em cooperativas, centros de triagem e indústrias de reaproveitamento.

        5. Conscientização social: Reciclar ensina sobre responsabilidade coletiva e mostra como pequenas atitudes individuais geram grandes impactos.

        6. Redução do volume de lixo: Ao reciclar, diminuímos a quantidade de resíduos em aterros sanitários e lixões, contribuindo para cidades mais limpas e sustentáveis.

        7. Proteção à saúde pública: O descarte incorreto de eletrônicos pode expor pessoas a metais pesados como chumbo e mercúrio, altamente prejudiciais à saúde.

        Reciclar é um ato de respeito com o planeta, com as futuras gerações e com nós mesmos.
        ''',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GreenDrop'),
        backgroundColor: const Color(0xFF57CC99),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Aprendendo a ser mais sustentável com GreenDrop',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                itemCount: cards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NewsDetailPage(
                            title: card['title']!,
                            content: card['content']!,
                            image: card['image'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF57CC99),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                card['title']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC7F9CC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Saiba mais →',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String? image;

  const NewsDetailPage({
    super.key,
    required this.title,
    required this.content,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF57CC99),
        title: const Text(
          'GreenDrop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TÍTULO
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D6A4F),
                ),
              ),
              const SizedBox(height: 16),

              // IMAGEM
              if (image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(image!, fit: BoxFit.cover),
                ),
              if (image != null) const SizedBox(height: 20),

              // CONTEÚDO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F5EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: content
                      .trim()
                      .split('\n')
                      .where((line) => line.trim().isNotEmpty)
                      .map((line) {
                        final parts = line.split(':');
                        if (parts.length < 2) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              line.trim(),
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Color(0xFF344E41),
                              ),
                            ),
                          );
                        }

                        final title = parts[0].trim();
                        final description = parts.sublist(1).join(':').trim();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B4332),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF344E41),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
