import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'local_store.dart';
import 'models.dart';

enum CatalogSort { relevance, bestSellers, lowestPrice, highestPrice, title }

class AppController extends ChangeNotifier {
  AppController({required SeboApiClient api, required LocalStore store})
    : _api = api,
      _store = store;

  final SeboApiClient _api;
  final LocalStore _store;

  bool booting = true;
  bool catalogLoading = false;
  bool ordersLoading = false;
  bool authLoading = false;
  bool checkoutLoading = false;

  String? catalogError;
  String? ordersError;

  AuthSession? session;
  List<Book> books = [];
  List<Order> orders = [];

  int tabIndex = 0;
  String catalogQuery = '';
  String? selectedCategory;
  bool freeShippingOnly = false;
  bool offersOnly = false;
  bool bestSellersOnly = false;
  bool newReleasesOnly = false;
  CatalogSort sort = CatalogSort.relevance;

  Map<int, int> _cart = {};

  bool get isLoggedIn => session != null;
  int get cartCount => _cart.values.fold(0, (sum, quantity) => sum + quantity);

  List<String> get categories {
    final values = books
        .map((book) => book.category)
        .where(isFilled)
        .toSet()
        .toList();
    values.sort((a, b) => a.compareTo(b));
    return values;
  }

  List<Book> get highlightedBooks {
    final list = [...books];
    list.sort((a, b) {
      final byHighlight = b.highlightScore.compareTo(a.highlightScore);
      if (byHighlight != 0) return byHighlight;
      return (b.rating ?? 0).compareTo(a.rating ?? 0);
    });
    return list
        .where((book) => book.canAddToCart)
        .take(8)
        .toList(growable: false);
  }

  List<Book> get dealBooks {
    return books
        .where(
          (book) => book.canAddToCart && (book.promotion || book.freeShipping),
        )
        .take(8)
        .toList(growable: false);
  }

  List<Book> get filteredBooks {
    final filtered = books.where((book) {
      if (!book.matchesQuery(catalogQuery)) {
        return false;
      }
      if (isFilled(selectedCategory) && book.category != selectedCategory) {
        return false;
      }
      if (freeShippingOnly && !book.freeShipping) {
        return false;
      }
      if (offersOnly && !book.promotion) {
        return false;
      }
      if (bestSellersOnly && !book.bestSeller) {
        return false;
      }
      if (newReleasesOnly && !book.newRelease) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      return switch (sort) {
        CatalogSort.lowestPrice => _compareNullablePrice(a, b, ascending: true),
        CatalogSort.highestPrice => _compareNullablePrice(
          a,
          b,
          ascending: false,
        ),
        CatalogSort.title => a.title.compareTo(b.title),
        CatalogSort.bestSellers => _compareByBestSeller(a, b),
        CatalogSort.relevance => _compareByRelevance(a, b),
      };
    });
    return filtered;
  }

  List<CartLine> get cartLines {
    final lines = <CartLine>[];
    for (final entry in _cart.entries) {
      final book = _bookById(entry.key);
      if (book == null || !book.canAddToCart) continue;
      final quantity = entry.value.clamp(1, book.stock).toInt();
      lines.add(CartLine(book: book, quantity: quantity));
    }
    return lines;
  }

  double get cartSubtotal =>
      cartLines.fold(0, (sum, line) => sum + line.subtotal);
  double get cartShipping =>
      cartLines.isNotEmpty && cartLines.every((line) => line.book.freeShipping)
      ? 0
      : 14.9;
  double get cartTotal => cartLines.isEmpty ? 0 : cartSubtotal + cartShipping;

  Future<void> boot() async {
    session = await _store.loadSession();
    _cart = await _store.loadCart();
    notifyListeners();

    await refreshCatalog();
    if (session != null) {
      await Future.wait([refreshAccount(), refreshOrders()]);
    }

    booting = false;
    notifyListeners();
  }

  Future<void> refreshCatalog() async {
    catalogLoading = true;
    catalogError = null;
    notifyListeners();

    try {
      books = await _api.fetchBooks();
      _normalizeCart();
      await _store.saveCart(_cart);
    } on ApiException catch (error) {
      catalogError = error.message;
    } catch (_) {
      catalogError = 'Nao foi possivel carregar o catalogo.';
    } finally {
      catalogLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshOrders() async {
    final token = session?.token;
    if (token == null) return;

    ordersLoading = true;
    ordersError = null;
    notifyListeners();

    try {
      orders = await _api.fetchOrders(token);
    } on ApiException catch (error) {
      ordersError = error.message;
      if (error.message.contains('sessao expirou')) {
        await logout();
      }
    } catch (_) {
      ordersError = 'Nao foi possivel carregar suas compras.';
    } finally {
      ordersLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAccount() async {
    final current = session;
    if (current == null) return;
    try {
      final user = await _api.me(current.token);
      session = current.copyWithUser(user);
      await _store.saveSession(session!);
    } catch (_) {
      // Account refresh is best-effort; the saved session still keeps the app usable.
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    authLoading = true;
    notifyListeners();
    try {
      session = await _api.login(email: email, password: password);
      await _store.saveSession(session!);
      await refreshOrders();
    } finally {
      authLoading = false;
      notifyListeners();
    }
  }

  Future<void> demoLogin() {
    return login('guest@exemplo.com', 'guest123');
  }

  Future<void> signUp(String name, String email, String password) async {
    authLoading = true;
    notifyListeners();
    try {
      session = await _api.signUp(name: name, email: email, password: password);
      await _store.saveSession(session!);
      await refreshOrders();
    } finally {
      authLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    session = null;
    orders = [];
    ordersError = null;
    await _store.clearSession();
    notifyListeners();
  }

  void goToTab(int index) {
    tabIndex = index;
    notifyListeners();
    if (index == 3 && isLoggedIn) {
      refreshOrders();
    }
    if (index == 4 && isLoggedIn) {
      refreshAccount();
    }
  }

  void setCatalogQuery(String value) {
    catalogQuery = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    selectedCategory = value;
    notifyListeners();
  }

  void toggleFreeShipping(bool value) {
    freeShippingOnly = value;
    notifyListeners();
  }

  void toggleOffers(bool value) {
    offersOnly = value;
    notifyListeners();
  }

  void toggleBestSellers(bool value) {
    bestSellersOnly = value;
    notifyListeners();
  }

  void toggleNewReleases(bool value) {
    newReleasesOnly = value;
    notifyListeners();
  }

  void setSort(CatalogSort value) {
    sort = value;
    notifyListeners();
  }

  void clearFilters() {
    catalogQuery = '';
    selectedCategory = null;
    freeShippingOnly = false;
    offersOnly = false;
    bestSellersOnly = false;
    newReleasesOnly = false;
    sort = CatalogSort.relevance;
    notifyListeners();
  }

  Future<void> addToCart(Book book) async {
    if (!book.canAddToCart) {
      throw const ApiException('Este livro esta indisponivel no momento.');
    }
    final nextQuantity = (_cart[book.id] ?? 0) + 1;
    if (nextQuantity > book.stock) {
      throw ApiException('Quantidade maxima disponivel: ${book.stock}.');
    }
    _cart[book.id] = nextQuantity;
    await _store.saveCart(_cart);
    notifyListeners();
  }

  Future<void> changeQuantity(Book book, int delta) async {
    final current = _cart[book.id] ?? 0;
    final next = (current + delta).clamp(0, book.stock).toInt();
    if (next <= 0) {
      _cart.remove(book.id);
    } else {
      _cart[book.id] = next;
    }
    await _store.saveCart(_cart);
    notifyListeners();
  }

  Future<void> removeFromCart(int bookId) async {
    _cart.remove(bookId);
    await _store.saveCart(_cart);
    notifyListeners();
  }

  Future<Order> checkout(CheckoutPayload payload) async {
    final token = session?.token;
    if (token == null) {
      throw const ApiException('Entre na sua conta para finalizar o pedido.');
    }
    if (payload.items.isEmpty) {
      throw const ApiException('Seu carrinho esta vazio.');
    }

    checkoutLoading = true;
    notifyListeners();
    try {
      final order = await _api.createOrder(token: token, payload: payload);
      _cart = {};
      await _store.saveCart(_cart);
      orders = [order, ...orders.where((item) => item.id != order.id)];
      tabIndex = 3;
      return order;
    } finally {
      checkoutLoading = false;
      notifyListeners();
    }
  }

  Book? _bookById(int id) {
    for (final book in books) {
      if (book.id == id) return book;
    }
    return null;
  }

  void _normalizeCart() {
    final normalized = <int, int>{};
    for (final entry in _cart.entries) {
      final book = _bookById(entry.key);
      if (book == null || !book.canAddToCart) continue;
      normalized[entry.key] = entry.value.clamp(1, book.stock).toInt();
    }
    _cart = normalized;
  }

  int _compareNullablePrice(Book a, Book b, {required bool ascending}) {
    final aPrice = a.price;
    final bPrice = b.price;
    if (aPrice == null && bPrice == null) return 0;
    if (aPrice == null) return 1;
    if (bPrice == null) return -1;
    return ascending ? aPrice.compareTo(bPrice) : bPrice.compareTo(aPrice);
  }

  int _compareByBestSeller(Book a, Book b) {
    final byBestSeller = (b.bestSeller ? 1 : 0).compareTo(a.bestSeller ? 1 : 0);
    if (byBestSeller != 0) return byBestSeller;
    return _compareByRelevance(a, b);
  }

  int _compareByRelevance(Book a, Book b) {
    final byHighlight = b.highlightScore.compareTo(a.highlightScore);
    if (byHighlight != 0) return byHighlight;
    return (b.rating ?? 0).compareTo(a.rating ?? 0);
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }
}
