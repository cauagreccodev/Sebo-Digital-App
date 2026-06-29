class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.authProvider,
    this.photoUrl,
    this.phone,
    this.mainAddress,
    this.complement,
    this.district,
    this.city,
    this.state,
    this.zipCode,
  });

  final int? id;
  final String name;
  final String email;
  final String role;
  final String authProvider;
  final String? photoUrl;
  final String? phone;
  final String? mainAddress;
  final String? complement;
  final String? district;
  final String? city;
  final String? state;
  final String? zipCode;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: asInt(json['id']),
      name: asText(json['nome'], fallback: 'Usuario'),
      email: asText(json['email']),
      role: asText(json['role'], fallback: 'USER'),
      authProvider: asText(json['authProvider'], fallback: 'LOCAL'),
      photoUrl: asNullableText(json['fotoUrl']),
      phone: asNullableText(json['telefone']),
      mainAddress: asNullableText(json['enderecoPrincipal']),
      complement: asNullableText(json['complemento']),
      district: asNullableText(json['bairro']),
      city: asNullableText(json['cidade']),
      state: asNullableText(json['estado']),
      zipCode: asNullableText(json['cep']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': name,
      'email': email,
      'role': role,
      'authProvider': authProvider,
      'fotoUrl': photoUrl,
      'telefone': phone,
      'enderecoPrincipal': mainAddress,
      'complemento': complement,
      'bairro': district,
      'cidade': city,
      'estado': state,
      'cep': zipCode,
    };
  }

  String get firstName {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    return parts.isEmpty ? 'Conta' : parts.first;
  }

  String get initials => initialsFrom(name);

  String get providerLabel {
    final provider = authProvider.toUpperCase();
    if (provider == 'GOOGLE') return 'Google';
    if (provider == 'FACEBOOK') return 'Facebook';
    return 'E-mail e senha';
  }

  String get fullAddress {
    return [
      mainAddress,
      complement,
      district,
      [city, state].where((part) => isFilled(part)).join(' - '),
      zipCode,
    ].where((part) => isFilled(part)).join('\n');
  }
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.type,
    required this.expiresAt,
    required this.user,
  });

  final String token;
  final String type;
  final DateTime? expiresAt;
  final User user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: asText(json['token']),
      type: asText(json['tipo'], fallback: 'Bearer'),
      expiresAt: DateTime.tryParse(asText(json['expiraEm'])),
      user: User.fromJson(asMap(json['usuario'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'tipo': type,
      'expiraEm': expiresAt?.toIso8601String(),
      'usuario': user.toJson(),
    };
  }

  bool get isExpired {
    final expiration = expiresAt;
    if (expiration == null) return false;
    return DateTime.now().isAfter(expiration);
  }

  AuthSession copyWithUser(User updatedUser) {
    return AuthSession(
      token: token,
      type: type,
      expiresAt: expiresAt,
      user: updatedUser,
    );
  }
}

class BookCopy {
  const BookCopy({
    required this.id,
    required this.seller,
    required this.sellerCity,
    required this.sellerRating,
    required this.type,
    required this.condition,
    required this.price,
    required this.stock,
    required this.city,
    required this.freeShipping,
    required this.promotion,
    required this.corporatePurchase,
    required this.active,
  });

  final int? id;
  final String seller;
  final String sellerCity;
  final double? sellerRating;
  final String type;
  final String condition;
  final double? price;
  final int stock;
  final String city;
  final bool freeShipping;
  final bool promotion;
  final bool corporatePurchase;
  final bool active;

  factory BookCopy.fromJson(Map<String, dynamic> json) {
    return BookCopy(
      id: asInt(json['id']),
      seller: asText(json['vendedor']),
      sellerCity: asText(json['cidadeVendedor']),
      sellerRating: asDouble(json['avaliacaoVendedor']),
      type: asText(json['tipo']),
      condition: asText(json['estadoConservacao']),
      price: asDouble(json['preco']),
      stock: asInt(json['estoque']) ?? 0,
      city: asText(json['cidade']),
      freeShipping: asBool(json['freteGratis']),
      promotion: asBool(json['promocao']),
      corporatePurchase: asBool(json['compraCorporativa']),
      active: json['ativo'] == null ? true : asBool(json['ativo']),
    );
  }
}

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.authorImageUrl,
    required this.publisher,
    required this.defaultSeller,
    required this.isbn,
    required this.language,
    required this.publicationYear,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.highlights,
    required this.copies,
    required this.lowestPrice,
    required this.totalStock,
  });

  final int id;
  final String title;
  final String author;
  final String? authorImageUrl;
  final String publisher;
  final String defaultSeller;
  final String isbn;
  final String language;
  final int? publicationYear;
  final String category;
  final String description;
  final String? imageUrl;
  final Map<String, dynamic> highlights;
  final List<BookCopy> copies;
  final double? lowestPrice;
  final int totalStock;

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: asInt(json['id']) ?? 0,
      title: asText(json['titulo'], fallback: 'Livro sem titulo'),
      author: asText(json['autor'], fallback: 'Autor nao informado'),
      authorImageUrl: asNullableText(json['autorImagemUrl']),
      publisher: asText(json['editora']),
      defaultSeller: asText(json['vendedora']),
      isbn: asText(json['isbn']),
      language: asText(json['idioma']),
      publicationYear: asInt(json['anoPublicacao']),
      category: asText(json['categoria'], fallback: 'Geral'),
      description: asText(json['descricao']),
      imageUrl: asNullableText(json['imagemUrl']),
      highlights: asMap(json['destaques']),
      copies: _parseCopies(json['copias']),
      lowestPrice: asDouble(json['menorPreco']),
      totalStock: asInt(json['estoqueTotal']) ?? 0,
    );
  }

  static List<BookCopy> _parseCopies(dynamic json) {
    final result = <BookCopy>[];
    final source = asMap(json);
    for (final key in const ['novas', 'usadas']) {
      final group = source[key];
      if (group is List) {
        for (final entry in group) {
          result.add(BookCopy.fromJson(asMap(entry)));
        }
      }
    }
    return result;
  }

  List<BookCopy> get activeCopies {
    return copies.where((copy) => copy.active).toList(growable: false);
  }

  BookCopy? get bestCopy {
    final available = activeCopies
        .where(
          (copy) => copy.id != null && copy.stock > 0 && copy.price != null,
        )
        .toList();
    final candidates = available.isNotEmpty
        ? available
        : activeCopies
              .where((copy) => copy.id != null && copy.price != null)
              .toList();
    if (candidates.isEmpty) {
      return activeCopies.isEmpty ? null : activeCopies.first;
    }

    candidates.sort((a, b) {
      final byPrice = (a.price ?? double.infinity).compareTo(
        b.price ?? double.infinity,
      );
      if (byPrice != 0) {
        return byPrice;
      }
      return b.stock.compareTo(a.stock);
    });
    return candidates.first;
  }

  int? get copyId => bestCopy?.id;
  double? get price => bestCopy?.price ?? lowestPrice;
  int get stock => bestCopy?.stock ?? totalStock;
  String get seller => displayText(bestCopy?.seller, fallback: defaultSeller);
  String get city =>
      displayText(bestCopy?.city, fallback: displayText(bestCopy?.sellerCity));
  String get typeLabel => enumLabel(bestCopy?.type ?? '');
  String get conditionLabel => enumLabel(bestCopy?.condition ?? '');
  double? get rating => bestCopy?.sellerRating;
  bool get freeShipping =>
      bestCopy?.freeShipping ?? copies.any((copy) => copy.freeShipping);
  bool get promotion => highlight('oferta') || (bestCopy?.promotion ?? false);
  bool get bestSeller => highlight('maisVendido');
  bool get newRelease => highlight('lancamento');
  bool get corporatePurchase => bestCopy?.corporatePurchase ?? false;
  bool get canAddToCart => copyId != null && price != null && stock > 0;

  int get highlightScore {
    return [
      bestSeller,
      promotion,
      newRelease,
      freeShipping,
    ].where((item) => item).length;
  }

  bool highlight(String key) => asBool(highlights[key]);

  bool matchesQuery(String query) {
    final normalized = normalize(query);
    if (normalized.isEmpty) return true;
    return [
      title,
      author,
      category,
      publisher,
      seller,
      city,
      description,
    ].any((field) => normalize(field).contains(normalized));
  }
}

class CartLine {
  const CartLine({required this.book, required this.quantity});

  final Book book;
  final int quantity;

  double get subtotal => (book.price ?? 0) * quantity;
}

class CheckoutPayload {
  const CheckoutPayload({
    required this.items,
    required this.deliveryAddress,
    required this.deliveryCity,
    required this.deliveryState,
    required this.deliveryZipCode,
    required this.paymentMethod,
  });

  final List<CartLine> items;
  final String deliveryAddress;
  final String deliveryCity;
  final String deliveryState;
  final String deliveryZipCode;
  final String paymentMethod;

  Map<String, dynamic> toJson() {
    return {
      'itens': items
          .map(
            (line) => {
              'livroCopiaId': line.book.copyId,
              'quantidade': line.quantity,
            },
          )
          .toList(),
      'enderecoEntrega': deliveryAddress,
      'cidadeEntrega': deliveryCity,
      'estadoEntrega': deliveryState,
      'cepEntrega': deliveryZipCode,
      'formaPagamento': paymentMethod,
    };
  }
}

class OrderItem {
  const OrderItem({
    required this.bookId,
    required this.bookCopyId,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.seller,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  final int? bookId;
  final int? bookCopyId;
  final String title;
  final String author;
  final String? imageUrl;
  final String seller;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      bookId: asInt(json['livroId']),
      bookCopyId: asInt(json['livroCopiaId']),
      title: asText(json['titulo'], fallback: 'Livro'),
      author: asText(json['autor']),
      imageUrl: asNullableText(json['imagemUrl']),
      seller: asText(json['vendedor']),
      quantity: asInt(json['quantidade']) ?? 1,
      unitPrice: asDouble(json['precoUnitario']) ?? 0,
      subtotal: asDouble(json['subtotal']) ?? 0,
    );
  }
}

class Order {
  const Order({
    required this.id,
    required this.code,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveryForecast,
    required this.deliveryAddress,
    required this.deliveryCity,
    required this.deliveryState,
    required this.deliveryZipCode,
    required this.paymentMethod,
    required this.trackingCode,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.items,
  });

  final int id;
  final String code;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveryForecast;
  final String deliveryAddress;
  final String deliveryCity;
  final String deliveryState;
  final String deliveryZipCode;
  final String paymentMethod;
  final String trackingCode;
  final double subtotal;
  final double shipping;
  final double total;
  final List<OrderItem> items;

  factory Order.fromJson(Map<String, dynamic> json) {
    final items = json['itens'] is List
        ? (json['itens'] as List)
              .map((item) => OrderItem.fromJson(asMap(item)))
              .toList(growable: false)
        : <OrderItem>[];
    return Order(
      id: asInt(json['id']) ?? 0,
      code: asText(json['codigo'], fallback: 'Pedido'),
      status: asText(json['status'], fallback: 'PEDIDO_REALIZADO'),
      createdAt: DateTime.tryParse(asText(json['criadoEm'])),
      updatedAt: DateTime.tryParse(asText(json['atualizadoEm'])),
      deliveryForecast: DateTime.tryParse(
        '${asText(json['previsaoEntrega'])}T12:00:00',
      ),
      deliveryAddress: asText(json['enderecoEntrega']),
      deliveryCity: asText(json['cidadeEntrega']),
      deliveryState: asText(json['estadoEntrega']),
      deliveryZipCode: asText(json['cepEntrega']),
      paymentMethod: asText(json['formaPagamento']),
      trackingCode: asText(json['codigoRastreio']),
      subtotal: asDouble(json['subtotal']) ?? 0,
      shipping: asDouble(json['frete']) ?? 0,
      total: asDouble(json['total']) ?? 0,
      items: items,
    );
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get delivered => status == 'ENTREGUE';
  String get statusLabel => orderStatusLabel(status);
}

const orderStatuses = [
  'PEDIDO_REALIZADO',
  'PAGAMENTO_APROVADO',
  'EM_SEPARACAO',
  'ENVIADO',
  'EM_TRANSPORTE',
  'ENTREGUE',
];

String orderStatusLabel(String status) {
  return switch (status) {
    'PEDIDO_REALIZADO' => 'Pedido realizado',
    'PAGAMENTO_APROVADO' => 'Pagamento aprovado',
    'EM_SEPARACAO' => 'Em separacao',
    'ENVIADO' => 'Enviado',
    'EM_TRANSPORTE' => 'Em transporte',
    'ENTREGUE' => 'Entregue',
    _ => enumLabel(status),
  };
}

Map<String, dynamic> asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

double? asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  final normalized = value.toString().replaceAll(',', '.');
  return double.tryParse(normalized);
}

int? asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == 'sim' || text == '1';
}

String asText(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String? asNullableText(dynamic value) {
  final text = asText(value);
  return text.isEmpty ? null : text;
}

bool isFilled(String? value) => value != null && value.trim().isNotEmpty;

String displayText(String? value, {String fallback = 'Nao informado'}) {
  return isFilled(value) ? value!.trim() : fallback;
}

String enumLabel(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return '';
  return normalized
      .toLowerCase()
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String initialsFrom(String value) {
  final letters = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
  return letters.isEmpty ? 'SD' : letters;
}

String normalize(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[áàâãä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòôõö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll('ç', 'c')
      .trim();
}
