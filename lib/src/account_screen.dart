import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'models.dart';
import 'sebo_theme.dart';
import 'ui_widgets.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final session = controller.session;
    if (session == null) {
      return AuthPanel(controller: controller);
    }

    final user = session.user;
    final activeOrders = controller.orders
        .where((order) => !order.delivered)
        .length;
    final completedOrders = controller.orders
        .where((order) => order.delivered)
        .length;

    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshAccount();
        await controller.refreshOrders();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: teal,
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sua conta',
                            style: TextStyle(
                              color: clay,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            user.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(color: muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        value: '${controller.orders.length}',
                        label: 'compras',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricTile(
                        value: '$activeOrders',
                        label: 'em andamento',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricTile(
                        value: '$completedOrders',
                        label: 'entregues',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _AccountInfo(user: user),
          const SizedBox(height: 14),
          _AccountActions(controller: controller),
        ],
      ),
    );
  }
}

class AuthPanel extends StatefulWidget {
  const AuthPanel({super.key, required this.controller});

  final AppController controller;

  @override
  State<AuthPanel> createState() => _AuthPanelState();
}

class _AuthPanelState extends State<AuthPanel> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController(text: 'guest@exemplo.com');
  final _password = TextEditingController(text: 'guest123');
  bool _creating = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionTitle(
          eyebrow: 'Conta',
          title: 'Entre para comprar e rastrear pedidos',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: line),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('Entrar'),
                      icon: Icon(Icons.login),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Criar conta'),
                      icon: Icon(Icons.person_add_alt),
                    ),
                  ],
                  selected: {_creating},
                  onSelectionChanged: (value) =>
                      setState(() => _creating = value.first),
                ),
                const SizedBox(height: 16),
                if (_creating) ...[
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().length < 3) {
                        return 'Informe seu nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (!text.contains('@')) return 'Informe um e-mail valido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if ((value ?? '').length < 6) {
                      return 'Use pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: controller.authLoading ? null : _submit,
                  icon: controller.authLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(_creating ? Icons.person_add_alt : Icons.login),
                  label: Text(_creating ? 'Criar conta' : 'Entrar'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: controller.authLoading ? null : _demoLogin,
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Entrar com a conta demo'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Demo: guest@exemplo.com / guest123',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      if (_creating) {
        await widget.controller.signUp(_name.text, _email.text, _password.text);
      } else {
        await widget.controller.login(_email.text, _password.text);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bem-vindo, ${widget.controller.session?.user.firstName ?? 'leitor'}.',
            ),
          ),
        );
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _demoLogin() async {
    try {
      await widget.controller.demoLogin();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta demonstrativa carregada.')),
        );
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }
}

class _AccountInfo extends StatelessWidget {
  const _AccountInfo({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados principais',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _DataLine('Login', user.providerLabel),
          _DataLine('Telefone', displayText(user.phone)),
          _DataLine(
            'Endereco',
            user.fullAddress.isEmpty ? 'Nao informado' : user.fullAddress,
          ),
        ],
      ),
    );
  }
}

class _DataLine extends StatelessWidget {
  const _DataLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
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

class _AccountActions extends StatelessWidget {
  const _AccountActions({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.goToTab(3),
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('Compras'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.goToTab(1),
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('Catalogo'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () async {
            await controller.logout();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voce saiu da sua conta.')),
              );
            }
          },
          style: FilledButton.styleFrom(backgroundColor: clay),
          icon: const Icon(Icons.logout),
          label: const Text('Sair da conta'),
        ),
      ],
    );
  }
}
