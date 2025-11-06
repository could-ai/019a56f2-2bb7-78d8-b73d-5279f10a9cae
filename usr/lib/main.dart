import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- Model ---
class Payment {
  final String clientName;
  final double debtAmount; // Monto de la deuda
  final double interestPaid; // Reditos pagados
  final double surchargePaid; // Recargo pagado
  final String description;
  final DateTime date;

  Payment({
    required this.clientName,
    required this.debtAmount,
    required this.interestPaid,
    required this.surchargePaid,
    required this.description,
    required this.date,
  });

  // Total pagado en esta transacción
  double get totalPaid => interestPaid + surchargePaid;
  
  // Saldo restante
  double get remainingBalance => debtAmount - totalPaid;
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
    Payment(
      clientName: "Marichel Kelly",
      debtAmount: 40.00,
      interestPaid: 8.00,
      surchargePaid: 4.00,
      description: "Pago de réditos y recargo",
      date: DateTime.now(),
    ),
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
                final balanceColor = payment.remainingBalance <= 0
                    ? Colors.green
                    : payment.totalPaid > 0
                        ? Colors.orange
                        : Colors.red;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      payment.clientName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Deuda: \$${payment.debtAmount.toStringAsFixed(2)}'),
                        Text('Pagado: \$${payment.totalPaid.toStringAsFixed(2)}'),
                        Text(
                          'Saldo: \$${payment.remainingBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: balanceColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.yMd().format(payment.date),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
  final _debtAmountController = TextEditingController();
  final _interestPaidController = TextEditingController();
  final _surchargePaidController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _clientNameController.dispose();
    _debtAmountController.dispose();
    _interestPaidController.dispose();
    _surchargePaidController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newPayment = Payment(
        clientName: _clientNameController.text,
        debtAmount: double.tryParse(_debtAmountController.text) ?? 0.0,
        interestPaid: double.tryParse(_interestPaidController.text) ?? 0.0,
        surchargePaid: double.tryParse(_surchargePaidController.text) ?? 0.0,
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
      body: SingleChildScrollView(
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
                controller: _debtAmountController,
                decoration: const InputDecoration(
                  labelText: 'Monto de la Deuda',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  helperText: 'Monto total que debe el cliente',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el monto de la deuda.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, ingrese un número válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _interestPaidController,
                decoration: const InputDecoration(
                  labelText: 'Réditos Pagados',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                  helperText: 'Intereses pagados en este pago',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese los réditos pagados.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, ingrese un número válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _surchargePaidController,
                decoration: const InputDecoration(
                  labelText: 'Recargo Pagado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.add_circle_outline),
                  helperText: 'Recargo adicional pagado',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el recargo pagado.';
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
                maxLines: 2,
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de imprimir no implementada.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de compartir no implementada.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                    'RECIBO DE PAGO',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(thickness: 2),
                const SizedBox(height: 16),
                Text(
                  'Fecha: ${DateFormat.yMMMMEEEEd('es_MX').format(payment.date)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cliente: ${payment.clientName}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Concepto: ${payment.description}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'DETALLE DEL PAGO',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Deuda Total:', payment.debtAmount),
                const SizedBox(height: 8),
                _buildDetailRow('Réditos Pagados:', payment.interestPaid, color: Colors.blue),
                const SizedBox(height: 8),
                _buildDetailRow('Recargo Pagado:', payment.surchargePaid, color: Colors.blue),
                const SizedBox(height: 16),
                const Divider(thickness: 2),
                const SizedBox(height: 16),
                _buildDetailRow('Total Pagado:', payment.totalPaid, isTotal: true, color: Colors.green),
                const SizedBox(height: 16),
                _buildDetailRow(
                  'Saldo Restante:',
                  payment.remainingBalance,
                  isTotal: true,
                  color: payment.remainingBalance > 0 ? Colors.red : Colors.green,
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    '¡Gracias por su pago!',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, double amount, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(amount),
          style: TextStyle(
            fontSize: isTotal ? 22 : 18,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
