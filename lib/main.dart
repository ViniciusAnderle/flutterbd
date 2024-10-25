// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutterbd/models/alimento.dart';
import 'package:flutterbd/helpers/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Mercado',
      theme: ThemeData(
        primarySwatch: Colors.green, // Mudança da cor primária para verde
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          headline6: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.green, // FAB verde
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();

  List<Alimento> _alimentos = [];
  bool _isLoading = false;

  Future<void> _loadAlimentos() async {
    setState(() => _isLoading = true);
    final alimentos = await SqlHelper().getAllAlimentos();
    setState(() {
      _alimentos = alimentos;
      _isLoading = false;
    });
  }

  Future<void> _addAlimento() async {
    setState(() => _isLoading = true);
    await SqlHelper().insertAlimento(
      Alimento(nome: "maça", preco: 5),
    );
    _nomeController.clear();
    _precoController.clear();
    await _loadAlimentos();
  }

  Future<void> _updateAlimento(int id) async {
    final alimento = _alimentos.firstWhere((element) => element.id == id);
    setState(() => _isLoading = true);
    await SqlHelper().updateAlimento(alimento);
    await _loadAlimentos();
  }

  Future<void> _deleteAlimento(int id) async {
    setState(() => _isLoading = true);
    await SqlHelper().deleteAlimento(id);
    await _loadAlimentos();
  }

  @override
  void initState() {
    super.initState();
    _loadAlimentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Mercado'),
        backgroundColor: Colors.green, // Cor personalizada para o AppBar
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _alimentos.length,
                itemBuilder: (context, index) {
                  final alimento = _alimentos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        alimento.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Preço: R\$${alimento.preco.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.green),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _updateAlimento(alimento.id!),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteAlimento(alimento.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlimento,
        tooltip: 'Adicionar Alimento',
        child: const Icon(Icons.add),
      ),
    );
  }
}
