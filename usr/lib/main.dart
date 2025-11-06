import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- Model ---
class Payment {
  final String clientName;
  final double amount;
  final String description;
  final DateTime date;

  Payment({
    required this.clientName,
    required this.amount,
    required this.description,
    required this.date,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Cobros',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// --- Screens ---

// HomeScreen: Displays the list of payments
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Payment> _payments = [
    Payment(clientName: "Cliente de Ejemplo", amount: 150.00, description: "Servicio de consultoría", date: DateTime.now()),
    Payment(clientName: "Otra Empresa S.A.", amount: 320.50, description: "Desarrollo de software", date: DateTime.now().subtract(const Duration(days: 2))),
  ];

  void _addPayment(Payment payment) {
    setState(() {
      _payments.insert(0, payment);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Cobros'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _payments.isEmpty
          ? const Center(
              child: Text(
                'No hay cobros registrados.\nPresiona "+" para agregar uno.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            NumberFormat.currency(symbol: '\$').format(payment.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer
                            ),
                          ),
                        ),
                      ),
                    ),
                    title: Text(payment.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(payment.description),
                    trailing: Text(DateFormat.yMd().format(payment.date)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReceiptScreen(payment: payment),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPayment = await Navigator.push<Payment>(
            context,
            MaterialPageRoute(builder: (context) => const AddPaymentScreen()),
          );
          if (newPayment != null) {
            _addPayment(newPayment);
          }
        },
        tooltip: 'Agregar Cobro',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// AddPaymentScreen: Form to add a new payment
class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _clientNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newPayment = Payment(
        clientName: _clientNameController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        description: _descriptionController.text,
        date: DateTime.now(),
      );
      Navigator.pop(context, newPayment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Cobro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del cliente.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un monto.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, ingrese un número válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                   prefixIcon: Icon(Icons.description),
                ),
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una descripción.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Guardar Cobro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ReceiptScreen: Displays the details of a payment
class ReceiptScreen extends StatelessWidget {
  final Payment payment;

  const ReceiptScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recibo de Pago'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // TODO: Implement printing functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de imprimir no implementada.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement sharing functionality
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de compartir no implementada.')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'RECIBO',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text('Fecha: ${DateFormat.yMMMMEEEEd('es_MX').format(payment.date)}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Text('Recibido de: ${payment.clientName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                Text('Por concepto de: ${payment.description}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('TOTAL: ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(
                      NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(payment.amount),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                 const SizedBox(height: 40),
                 const Center(child: Text('¡Gracias por su pago!', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
