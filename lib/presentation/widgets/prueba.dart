import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/divisa_provider.dart';

class TestDivisasPage extends ConsumerWidget {
  const TestDivisasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final divisasAsync = ref.watch(divisasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Test Divisas")),

      body: divisasAsync.when(
        data: (divisas) {
          print("🔥 DIVISAS: $divisas"); // 👈 IMPORTANTE

          return ListView.builder(
            itemCount: divisas.length,
            itemBuilder: (_, i) {
              final d = divisas[i];
              return ListTile(
                title: Column(
                  children: [
                    Text(d.parone),
                    Text(d.partwo),
                  ],
                ),
                subtitle: Text(d.id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          print("❌ ERROR: $e");
          return Center(child: Text("Error: $e"));
        },
      ),
    );
  }
}