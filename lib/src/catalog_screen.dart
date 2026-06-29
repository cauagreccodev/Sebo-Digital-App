import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'sebo_theme.dart';
import 'ui_widgets.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final TextEditingController _search;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.controller.catalogQuery);
  }

  @override
  void dispose() {
    _search.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (!_focusNode.hasFocus && _search.text != controller.catalogQuery) {
      _search.text = controller.catalogQuery;
    }

    final books = controller.filteredBooks;

    return RefreshIndicator(
      onRefresh: controller.refreshCatalog,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    eyebrow: 'Catalogo',
                    title:
                        '${books.length} ${books.length == 1 ? 'livro encontrado' : 'livros encontrados'}',
                    trailing: TextButton.icon(
                      onPressed: controller.clearFilters,
                      icon: const Icon(Icons.filter_alt_off_outlined),
                      label: const Text('Limpar'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _search,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.search,
                    onChanged: controller.setCatalogQuery,
                    decoration: const InputDecoration(
                      hintText: 'Titulo, autor, categoria, vendedor...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Filters(controller: controller),
                  const SizedBox(height: 12),
                  _SortRow(controller: controller),
                ],
              ),
            ),
          ),
          if (controller.catalogLoading && controller.books.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (controller.catalogError != null && controller.books.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Catalogo indisponivel',
                  message: controller.catalogError!,
                  action: FilledButton.icon(
                    onPressed: controller.refreshCatalog,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ),
              ),
            )
          else if (books.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: EmptyState(
                  icon: Icons.search_off_outlined,
                  title: 'Nenhum livro encontrado',
                  message:
                      'Ajuste os filtros ou limpe a busca para ver mais resultados.',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final columns = width >= 1000
                      ? 4
                      : width >= 740
                      ? 3
                      : width >= 520
                      ? 2
                      : 1;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 378,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          BookCard(book: books[index], controller: controller),
                      childCount: books.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                selected: controller.freeShippingOnly,
                onSelected: controller.toggleFreeShipping,
                label: const Text('Frete gratis'),
                avatar: const Icon(Icons.local_shipping_outlined, size: 18),
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: controller.offersOnly,
                onSelected: controller.toggleOffers,
                label: const Text('Ofertas'),
                avatar: const Icon(Icons.sell_outlined, size: 18),
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: controller.bestSellersOnly,
                onSelected: controller.toggleBestSellers,
                label: const Text('Mais vendidos'),
                avatar: const Icon(Icons.trending_up, size: 18),
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: controller.newReleasesOnly,
                onSelected: controller.toggleNewReleases,
                label: const Text('Lancamentos'),
                avatar: const Icon(Icons.auto_awesome_outlined, size: 18),
              ),
            ],
          ),
        ),
        if (controller.categories.isNotEmpty) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  selected: controller.selectedCategory == null,
                  onSelected: (_) => controller.setCategory(null),
                  label: const Text('Todas'),
                ),
                const SizedBox(width: 8),
                for (final category in controller.categories) ...[
                  ChoiceChip(
                    selected: controller.selectedCategory == category,
                    onSelected: (_) => controller.setCategory(category),
                    label: Text(category),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.sort, color: context.seboMuted, size: 19),
        const SizedBox(width: 8),
        Text(
          'Ordenar por',
          style: TextStyle(
            color: context.seboMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        DropdownButton<CatalogSort>(
          value: controller.sort,
          underline: const SizedBox.shrink(),
          borderRadius: BorderRadius.circular(8),
          items: const [
            DropdownMenuItem(
              value: CatalogSort.relevance,
              child: Text('Relevancia'),
            ),
            DropdownMenuItem(
              value: CatalogSort.bestSellers,
              child: Text('Mais vendidos'),
            ),
            DropdownMenuItem(
              value: CatalogSort.lowestPrice,
              child: Text('Menor preco'),
            ),
            DropdownMenuItem(
              value: CatalogSort.highestPrice,
              child: Text('Maior preco'),
            ),
            DropdownMenuItem(value: CatalogSort.title, child: Text('Titulo')),
          ],
          onChanged: (value) {
            if (value != null) controller.setSort(value);
          },
        ),
      ],
    );
  }
}
