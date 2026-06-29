import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'models.dart';
import 'sebo_theme.dart';
import 'ui_widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final lines = controller.cartLines;

    if (lines.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Seu carrinho esta vazio',
            message:
                'Escolha alguns livros no catalogo para montar sua compra.',
            action: FilledButton.icon(
              onPressed: () => controller.goToTab(1),
              icon: const Icon(Icons.menu_book),
              label: const Text('Ver catalogo'),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionTitle(eyebrow: 'Carrinho', title: 'Revise sua compra'),
        const SizedBox(height: 14),
        for (final line in lines) ...[
          _CartItem(line: line, controller: controller),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        _SummaryPanel(controller: controller),
      ],
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({required this.line, required this.controller});

  final CartLine line;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final book = line.book;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: lineColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 76,
              height: 112,
              child: BookCover(book: book, compact: true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${book.author} - ${book.typeLabel} - ${book.conditionLabel}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  money(line.subtotal),
                  style: const TextStyle(
                    color: tealDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onPressed: () => controller.changeQuantity(book, -1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${line.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onPressed: line.quantity >= book.stock
                          ? null
                          : () => controller.changeQuantity(book, 1),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Remover',
                      onPressed: () => controller.removeFromCart(book.id),
                      icon: const Icon(Icons.delete_outline, color: clay),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo da compra',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _SummaryRow(label: 'Subtotal', value: money(controller.cartSubtotal)),
          _SummaryRow(
            label: 'Frete',
            value: controller.cartShipping == 0
                ? 'Gratis'
                : money(controller.cartShipping),
          ),
          const Divider(height: 24),
          _SummaryRow(
            label: 'Total',
            value: money(controller.cartTotal),
            strong: true,
          ),
          const SizedBox(height: 16),
          if (!controller.isLoggedIn)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Entre na sua conta para informar a entrega e finalizar o pedido.',
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => controller.goToTab(4),
                  icon: const Icon(Icons.login),
                  label: const Text('Entrar para continuar'),
                ),
              ],
            )
          else
            FilledButton.icon(
              onPressed: controller.checkoutLoading
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CheckoutPage(controller: controller),
                        ),
                      );
                    },
              icon: controller.checkoutLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_outline),
              label: const Text('Finalizar pedido'),
            ),
          const SizedBox(height: 10),
          const Text(
            'Ambiente demonstrativo: nenhuma cobranca real sera realizada.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: muted)),
          ),
          Text(
            value,
            style: TextStyle(
              color: strong ? tealDark : ink,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
              fontSize: strong ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _zipCode;
  String _payment = 'PIX';

  @override
  void initState() {
    super.initState();
    final user = widget.controller.session?.user;
    final address = [
      user?.mainAddress,
      user?.complement,
    ].where(isFilled).join(' - ');
    _address = TextEditingController(text: address);
    _city = TextEditingController(text: user?.city ?? '');
    _state = TextEditingController(text: user?.state ?? '');
    _zipCode = TextEditingController(text: user?.zipCode ?? '');
  }

  @override
  void dispose() {
    _address.dispose();
    _city.dispose();
    _state.dispose();
    _zipCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Entrega e pagamento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionTitle(
              eyebrow: 'Checkout',
              title: 'Dados para finalizar',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(
                labelText: 'Endereco e numero',
                prefixIcon: Icon(Icons.home_outlined),
              ),
              maxLength: 240,
              validator: _required,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _city,
                    decoration: const InputDecoration(labelText: 'Cidade'),
                    maxLength: 120,
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _state,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'UF'),
                    maxLength: 2,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (!RegExp(r'^[A-Za-z]{2}$').hasMatch(text)) {
                        return 'UF';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _zipCode,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'CEP',
                hintText: '00000-000',
                prefixIcon: Icon(Icons.pin_drop_outlined),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (!RegExp(r'^\d{5}-?\d{3}$').hasMatch(text)) {
                  return 'Informe um CEP valido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _payment,
              decoration: const InputDecoration(
                labelText: 'Forma de pagamento',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'PIX', child: Text('PIX')),
                DropdownMenuItem(
                  value: 'Cartao de credito',
                  child: Text('Cartao de credito'),
                ),
                DropdownMenuItem(value: 'Boleto', child: Text('Boleto')),
              ],
              onChanged: (value) => setState(() => _payment = value ?? 'PIX'),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: lineColor),
              ),
              child: Column(
                children: [
                  _SummaryRow(label: 'Itens', value: '${controller.cartCount}'),
                  _SummaryRow(
                    label: 'Subtotal',
                    value: money(controller.cartSubtotal),
                  ),
                  _SummaryRow(
                    label: 'Frete',
                    value: controller.cartShipping == 0
                        ? 'Gratis'
                        : money(controller.cartShipping),
                  ),
                  const Divider(height: 24),
                  _SummaryRow(
                    label: 'Total',
                    value: money(controller.cartTotal),
                    strong: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: controller.checkoutLoading ? null : _submit,
              icon: controller.checkoutLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: const Text('Finalizar pedido'),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Campo obrigatorio';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final order = await widget.controller.checkout(
        CheckoutPayload(
          items: widget.controller.cartLines,
          deliveryAddress: _address.text.trim(),
          deliveryCity: _city.text.trim(),
          deliveryState: _state.text.trim().toUpperCase(),
          deliveryZipCode: _zipCode.text.trim(),
          paymentMethod: _payment,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido ${order.code} realizado com sucesso.')),
      );
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }
}

const lineColor = line;
