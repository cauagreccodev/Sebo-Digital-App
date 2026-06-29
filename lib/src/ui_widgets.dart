import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'models.dart';
import 'sebo_theme.dart';

class SeboLogo extends StatelessWidget {
  const SeboLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 36 : 42,
          height: compact ? 36 : 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(colors: [wine, clay]),
          ),
          child: Text(
            'SD',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 13 : 15,
              letterSpacing: 0,
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sebo Digital',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
              Text(
                'livros usados e achados raros',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class CartBadgeIcon extends StatelessWidget {
  const CartBadgeIcon({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_bag_outlined),
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Color(0xFF2E2615),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.eyebrow,
    this.trailing,
  });

  final String title;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null)
                Text(
                  eyebrow!,
                  style: const TextStyle(
                    color: clay,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                ),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: teal, size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted),
          ),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}

class BookShelf extends StatelessWidget {
  const BookShelf({super.key, required this.books, required this.controller});

  final List<Book> books;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const EmptyState(
        icon: Icons.menu_book_outlined,
        title: 'Nenhum livro encontrado',
        message: 'Atualize o catalogo ou ajuste sua busca.',
      );
    }

    return SizedBox(
      height: 378,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 238,
            child: BookCard(book: books[index], controller: controller),
          );
        },
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book, required this.controller});

  final Book book;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: line),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BookDetailPage(book: book, controller: controller),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: BookCover(book: book, compact: true)),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (book.conditionLabel.isNotEmpty)
                          MiniTag(book.conditionLabel),
                        MiniTag(
                          book.freeShipping
                              ? 'Frete gratis'
                              : 'Frete calculado',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            money(book.price),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: tealDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          tooltip: book.canAddToCart
                              ? 'Adicionar ao carrinho'
                              : 'Indisponivel',
                          onPressed: book.canAddToCart
                              ? () => _addToCart(context)
                              : null,
                          icon: const Icon(Icons.add_shopping_cart, size: 19),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    try {
      await controller.addToCart(book);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${book.title} foi adicionado ao carrinho.')),
        );
      }
    } on ApiException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }
}

class BookCover extends StatelessWidget {
  const BookCover({super.key, required this.book, this.compact = false});

  final Book book;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final imageUrl = book.imageUrl;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _coverColors(book),
        ),
      ),
      child: imageUrl == null
          ? _FallbackCover(book: book, compact: compact)
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  _FallbackCover(book: book, compact: compact),
              loadingBuilder: (context, child, loading) {
                if (loading == null) return child;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    _FallbackCover(book: book, compact: compact),
                    const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  List<Color> _coverColors(Book book) {
    final palette = const [
      [wine, clay],
      [teal, tealDark],
      [Color(0xFF345C78), sky],
      [Color(0xFF7A6A2E), gold],
      [Color(0xFF567A52), sage],
    ];
    return palette[book.id.abs() % palette.length];
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover({required this.book, required this.compact});

  final Book book;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(compact ? 14 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              book.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          const Spacer(),
          Text(
            book.title,
            maxLines: compact ? 3 : 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 18 : 28,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.author,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniTag extends StatelessWidget {
  const MiniTag(this.label, {super.key, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color ?? paperStrong,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: inkSoft,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
  });

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: paperStrong,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, color: teal, size: 18),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: tealDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: muted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: sage,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: tealDark,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class BookDetailPage extends StatelessWidget {
  const BookDetailPage({
    super.key,
    required this.book,
    required this.controller,
  });

  final Book book;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final notes = [
      if (book.typeLabel.isNotEmpty) book.typeLabel,
      if (book.conditionLabel.isNotEmpty) book.conditionLabel,
      if (book.language.isNotEmpty) book.language,
      if (book.publicationYear != null) '${book.publicationYear}',
      if (book.freeShipping) 'Frete gratis',
      if (book.promotion) 'Oferta',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do livro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              final cover = ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: wide ? 520 : 430,
                  child: BookCover(book: book),
                ),
              );
              final details = _DetailContent(
                book: book,
                notes: notes,
                controller: controller,
              );

              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [cover, const SizedBox(height: 20), details],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: cover),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: details),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.book,
    required this.notes,
    required this.controller,
  });

  final Book book;
  final List<String> notes;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.category,
          style: const TextStyle(
            color: clay,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          book.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'por ${book.author}',
          style: const TextStyle(
            color: inkSoft,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: notes.map(MiniTag.new).toList(),
        ),
        const SizedBox(height: 18),
        Text(
          money(book.price),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: tealDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          book.stock > 0
              ? '${book.stock} unidade(s) em estoque'
              : 'Indisponivel',
          style: const TextStyle(color: muted, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: book.canAddToCart
              ? () async {
                  try {
                    await controller.addToCart(book);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${book.title} foi adicionado ao carrinho.',
                          ),
                        ),
                      );
                    }
                  } on ApiException catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.message)));
                    }
                  }
                }
              : null,
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Adicionar ao carrinho'),
        ),
        const SizedBox(height: 22),
        _InfoBlock(
          title: 'Sobre esta oferta',
          children: [
            _InfoRow('Vendedor', book.seller),
            _InfoRow('Cidade', displayText(book.city)),
            _InfoRow('Editora', displayText(book.publisher)),
            if (book.rating != null)
              _InfoRow(
                'Avaliacao',
                '${book.rating!.toStringAsFixed(1)} estrelas',
              ),
            if (book.isbn.isNotEmpty) _InfoRow('ISBN', book.isbn),
          ],
        ),
        if (book.description.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'Descricao',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            book.description,
            style: const TextStyle(color: inkSoft, height: 1.45),
          ),
        ],
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

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
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: muted, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
