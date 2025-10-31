import 'package:flutter/material.dart';
import 'bajaj_api_service.dart';
import 'basket_model.dart';

class BasketListScreen extends StatefulWidget {
  const BasketListScreen({super.key});

  @override
  State<BasketListScreen> createState() => _BasketListScreenState();
}

class _BasketListScreenState extends State<BasketListScreen> {
  late final BasketService _service;
  late Future<List<Basket>> _futureBaskets;

  @override
  void initState() {
    super.initState();
    _service = BasketService();
    _futureBaskets = _service.fetchBaskets();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureBaskets = _service.fetchBaskets();
    });
  }

  void _showDetails(Basket basket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BasketDetailSheet(basket: basket),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classia Baskets'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Basket>>(
          future: _futureBaskets,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    TextButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              );
            }

            final baskets = snapshot.data!;
            if (baskets.isEmpty) {
              return const Center(child: Text('No baskets found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: baskets.length,
              itemBuilder: (context, index) {
                final basket = baskets[index];
                return CompactBasketCard(
                  basket: basket,
                  onTap: () => _showDetails(basket),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ===============================================
// COMPACT CARD WITH HORSE RUNNING PERFORMANCE
// ===============================================
class CompactBasketCard extends StatelessWidget {
  final Basket basket;
  final VoidCallback onTap;

  const CompactBasketCard({super.key, required this.basket, required this.onTap});

  Color _volatilityColor(String vol) {
    switch (vol) {
      case 'LOW': return Colors.green.shade100;
      case 'MID': return Colors.orange.shade100;
      case 'HIGH': return Colors.red.shade100;
      default: return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double performance = double.tryParse(basket.expectedReturn) ?? 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Name + Horse + Return
              Row(
                children: [
                  Expanded(
                    child: Text(
                      basket.basketName,
                      style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: HorseProgressBar(performance: performance / 100),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${basket.expectedReturn}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Chips Row
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _miniChip(basket.subscryptionType, Colors.blue.shade100),
                  _miniChip(basket.volatility, _volatilityColor(basket.volatility)),
                  _miniChip('₹${basket.subscriptionAmount}', Colors.purple.shade100),
                ],
              ),
              const SizedBox(height: 8),

              // RA + Holdings count
              Row(
                children: [
                  Text('RA: ${basket.raName}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const Spacer(),
                  Text(
                    '${basket.holdings.length} holding${basket.holdings.length != 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),


              // Status

            ],
          ),
        ),
      ),
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

// ===============================================
// HORSE RUNNING PROGRESS BAR
// ===============================================
class HorseProgressBar extends StatelessWidget {
  final double performance; // 0.0 to 1.0

  const HorseProgressBar({super.key, required this.performance});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          height: 20,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        FractionallySizedBox(
          widthFactor: performance.clamp(0.0, 1.0),
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          left: (performance.clamp(0.0, 1.0) * 80) - 16,
          child: const Text('Horse', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

// ===============================================
// DETAILED BOTTOM SHEET
// ===============================================
class BasketDetailSheet extends StatelessWidget {
  final Basket basket;

  const BasketDetailSheet({super.key, required this.basket});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header
                    Text(basket.basketName, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Expected Return: ${basket.expectedReturn}%', style: const TextStyle(fontSize: 18, color: Colors.green)),
                    const Divider(height: 32),

                    // Info Chips
                    Wrap(
                      spacing: 12,
                      children: [
                        Chip(label: Text(basket.subscryptionType)),
                        Chip(label: Text(basket.volatility)),
                        Chip(label: Text('₹${basket.subscriptionAmount}')),
                        Chip(label: Text('RA: ${basket.raName}')),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Holdings
                    const Text('Holdings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (basket.holdings.isEmpty)
                      const Text('No holdings added yet.')
                    else
                      ...basket.holdings.map((h) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: Colors.indigo, child: Text('${h.stockId}')),
                          title: Text('Stock #${h.stockId}'),
                          subtitle: Text('${h.holdinPercentage}% allocation'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (h.tgtPrice != '0') Text('Target: ₹${h.tgtPrice}', style: const TextStyle(color: Colors.green)),
                              const SizedBox(width: 8),
                              if (h.slPrice != '0') Text('SL: ₹${h.slPrice}', style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}