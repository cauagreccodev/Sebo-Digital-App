import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'models.dart';
import 'sebo_theme.dart';
import 'ui_widgets.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.isLoggedIn) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EmptyState(
            icon: Icons.local_shipping_outlined,
            title: 'Entre para ver suas compras',
            message:
                'Seu historico e o rastreamento ficam vinculados a sua conta.',
            action: FilledButton.icon(
              onPressed: () => controller.goToTab(4),
              icon: const Icon(Icons.login),
              label: const Text('Entrar ou criar conta'),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshOrders,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionTitle(
            eyebrow: 'Compras',
            title: 'Seus pedidos',
            trailing: IconButton(
              tooltip: 'Atualizar pedidos',
              onPressed: controller.ordersLoading
                  ? null
                  : controller.refreshOrders,
              icon: controller.ordersLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
          ),
          const SizedBox(height: 14),
          if (controller.ordersError != null) ...[
            EmptyState(
              icon: Icons.error_outline,
              title: 'Nao foi possivel carregar suas compras',
              message: controller.ordersError!,
              action: FilledButton.icon(
                onPressed: controller.refreshOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar de novo'),
              ),
            ),
          ] else if (controller.ordersLoading && controller.orders.isEmpty) ...[
            const SizedBox(height: 120),
            const Center(child: CircularProgressIndicator()),
          ] else if (controller.orders.isEmpty) ...[
            EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Voce ainda nao fez nenhuma compra',
              message:
                  'Quando finalizar um pedido, ele aparecera aqui com rastreamento.',
              action: FilledButton.icon(
                onPressed: () => controller.goToTab(1),
                icon: const Icon(Icons.menu_book),
                label: const Text('Explorar livros'),
              ),
            ),
          ] else ...[
            for (final order in controller.orders) ...[
              _OrderCard(order: order),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: line),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          'Pedido ${order.code}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateTimeLabel(order.createdAt),
                style: const TextStyle(color: muted),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusPill(label: order.statusLabel),
                  MiniTag(
                    '${order.itemCount} ${order.itemCount == 1 ? 'livro' : 'livros'}',
                  ),
                  MiniTag(money(order.total)),
                ],
              ),
            ],
          ),
        ),
        children: [
          _Tracking(order: order),
          const SizedBox(height: 14),
          _OrderInfo(order: order),
          const SizedBox(height: 14),
          for (final item in order.items) _OrderItemRow(item: item),
        ],
      ),
    );
  }
}

class _Tracking extends StatelessWidget {
  const _Tracking({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final current = orderStatuses
        .indexOf(order.status)
        .clamp(0, orderStatuses.length - 1)
        .toInt();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: paperStrong,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_outlined, color: teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.statusLabel,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                shortDate(order.deliveryForecast),
                style: const TextStyle(color: muted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < orderStatuses.length; index++) ...[
                  _TrackingStep(
                    label: orderStatusLabel(orderStatuses[index]),
                    done: index <= current,
                    current: index == current,
                  ),
                  if (index < orderStatuses.length - 1)
                    Container(
                      width: 34,
                      height: 2,
                      color: index < current ? teal : line,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  const _TrackingStep({
    required this.label,
    required this.done,
    required this.current,
  });

  final String label;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? teal : surface,
              border: Border.all(color: current ? tealDark : line),
              shape: BoxShape.circle,
            ),
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 15)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: current ? tealDark : muted,
              fontSize: 10,
              fontWeight: current ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderInfo extends StatelessWidget {
  const _OrderInfo({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoLine(
          'Entrega',
          '${order.deliveryAddress}\n${order.deliveryCity} - ${order.deliveryState}, ${order.deliveryZipCode}',
        ),
        _InfoLine('Pagamento', order.paymentMethod),
        if (order.trackingCode.isNotEmpty)
          _InfoLine('Rastreio', order.trackingCode),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: const TextStyle(color: muted, fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sage,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              initialsFrom(item.title),
              style: const TextStyle(
                color: tealDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '${item.author} - ${item.seller}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                Text(
                  'Quantidade: ${item.quantity}',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            money(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
