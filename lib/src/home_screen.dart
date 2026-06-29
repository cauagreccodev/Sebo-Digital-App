import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'sebo_theme.dart';
import 'ui_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return RefreshIndicator(
      onRefresh: controller.refreshCatalog,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _HeroSearch(
            search: _search,
            onSearch: (value) {
              controller.setCatalogQuery(value);
              controller.setCategory(null);
              controller.goToTab(1);
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.catalogError != null) ...[
                  EmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: 'Catalogo indisponivel',
                    message: controller.catalogError!,
                    action: FilledButton.icon(
                      onPressed: controller.refreshCatalog,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar de novo'),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
                SectionTitle(
                  eyebrow: 'Destaques',
                  title: 'Livros para garimpar hoje',
                  trailing: TextButton(
                    onPressed: () => controller.goToTab(1),
                    child: const Text('Ver catalogo'),
                  ),
                ),
                const SizedBox(height: 14),
                BookShelf(
                  books: controller.highlightedBooks.isEmpty
                      ? controller.books.take(8).toList()
                      : controller.highlightedBooks,
                  controller: controller,
                ),
                const SizedBox(height: 28),
                const SectionTitle(
                  eyebrow: 'Categorias',
                  title: 'Caminhos rapidos',
                ),
                const SizedBox(height: 14),
                _CategoryGrid(controller: controller),
                const SizedBox(height: 28),
                const SectionTitle(
                  eyebrow: 'Ofertas',
                  title: 'Precos bons e frete esperto',
                ),
                const SizedBox(height: 14),
                BookShelf(
                  books: controller.dealBooks.isEmpty
                      ? controller.books.take(8).toList()
                      : controller.dealBooks,
                  controller: controller,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSearch extends StatelessWidget {
  const _HeroSearch({required this.search, required this.onSearch});

  final TextEditingController search;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 330),
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tealDark, teal, wine],
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sebo Digital',
                style: TextStyle(
                  color: gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Encontre livros usados, ofertas e edicoes que merecem outra prateleira.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.06,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Catalogo conectado a API em producao, com carrinho, compras e rastreamento.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.84),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: search,
                textInputAction: TextInputAction.search,
                onSubmitted: onSearch,
                decoration: InputDecoration(
                  hintText: 'Busque por titulo, autor, editora ou cidade',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Pesquisar',
                    onPressed: () => onSearch(search.text),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickSearch(
                    label: 'Mais vendidos',
                    value: 'mais vendidos',
                    onSearch: onSearch,
                  ),
                  _QuickSearch(
                    label: 'Frete gratis',
                    value: 'frete gratis',
                    onSearch: onSearch,
                  ),
                  _QuickSearch(
                    label: 'Literatura',
                    value: 'literatura',
                    onSearch: onSearch,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickSearch extends StatelessWidget {
  const _QuickSearch({
    required this.label,
    required this.value,
    required this.onSearch,
  });

  final String label;
  final String value;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final chipBackground = context.isSeboDark ? darkSurface : surface;
    final chipTextColor = context.isSeboDark ? darkInk : tealDark;

    return ActionChip(
      label: Text(label),
      avatar: Icon(Icons.auto_stories, color: chipTextColor, size: 17),
      onPressed: () => onSearch(value),
      backgroundColor: chipBackground,
      side: BorderSide(color: context.isSeboDark ? darkLine : Colors.white),
      labelStyle: TextStyle(color: chipTextColor, fontWeight: FontWeight.w800),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final categories = controller.categories.take(6).toList();
    if (categories.isEmpty) {
      return const EmptyState(
        icon: Icons.category_outlined,
        title: 'Categorias indisponiveis',
        message: 'Assim que o catalogo carregar, os atalhos aparecem aqui.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760
            ? 3
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 118,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                controller.setCategory(category);
                controller.setCatalogQuery('');
                controller.goToTab(1);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: index.isEven
                      ? context.seboSurface
                      : context.seboSurfaceMuted,
                  border: Border.all(color: context.seboLine),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_categoryIcon(category), color: context.seboTeal),
                    const Spacer(),
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.seboInk,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Explorar livros',
                      style: TextStyle(
                        color: context.seboTeal,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _categoryIcon(String category) {
    final text = category.toLowerCase();
    if (text.contains('infantil')) return Icons.child_care;
    if (text.contains('tecn')) return Icons.memory;
    if (text.contains('hist')) return Icons.history_edu;
    if (text.contains('arte')) return Icons.palette_outlined;
    if (text.contains('neg')) return Icons.business_center_outlined;
    return Icons.local_library_outlined;
  }
}
