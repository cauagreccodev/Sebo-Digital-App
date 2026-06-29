import 'package:flutter/material.dart';

import 'account_screen.dart';
import 'api_client.dart';
import 'app_controller.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'home_screen.dart';
import 'local_store.dart';
import 'purchases_screen.dart';
import 'sebo_theme.dart';
import 'ui_widgets.dart';

class SeboDigitalApp extends StatefulWidget {
  const SeboDigitalApp({super.key});

  @override
  State<SeboDigitalApp> createState() => _SeboDigitalAppState();
}

class _SeboDigitalAppState extends State<SeboDigitalApp> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    controller = AppController(api: SeboApiClient(), store: LocalStore());
    controller.boot();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'Sebo Digital',
          debugShowCheckedModeBanner: false,
          theme: buildSeboTheme(),
          home: AppShell(controller: controller),
        );
      },
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(controller: controller),
      CatalogScreen(controller: controller),
      CartScreen(controller: controller),
      PurchasesScreen(controller: controller),
      AccountScreen(controller: controller),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => controller.goToTab(0),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: SeboLogo(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar catalogo',
            onPressed: controller.catalogLoading
                ? null
                : controller.refreshCatalog,
            icon: controller.catalogLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Carrinho',
            onPressed: () => controller.goToTab(2),
            icon: CartBadgeIcon(count: controller.cartCount),
          ),
          IconButton(
            tooltip: controller.isLoggedIn ? 'Minha conta' : 'Entrar',
            onPressed: () => controller.goToTab(4),
            icon: Icon(
              controller.isLoggedIn
                  ? Icons.account_circle
                  : Icons.person_outline,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: controller.booting && controller.books.isEmpty
            ? const _BootView()
            : IndexedStack(index: controller.tabIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: controller.tabIndex,
        onDestinationSelected: controller.goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Catalogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Carrinho',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'Compras',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Conta',
          ),
        ],
      ),
    );
  }
}

class _BootView extends StatelessWidget {
  const _BootView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SeboLogo(),
          SizedBox(height: 22),
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Carregando catalogo...'),
        ],
      ),
    );
  }
}
