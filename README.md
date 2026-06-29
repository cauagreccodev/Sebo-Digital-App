# Sebo Digital App

Aplicativo mobile em Flutter/Dart para o Sebo Digital.

## API e banco de dados

O app mobile usa a mesma API da versao web:

```text
https://sebo-digital-site-production.up.railway.app
```

O banco de dados ja existe e continua sendo acessado pelo backend Spring Boot.
O app nao cria banco, nao faz seed e nao conecta diretamente ao PostgreSQL.

Para trocar a API em desenvolvimento:

```powershell
flutter run -t lib/main.dart --dart-define=SEBO_API_URL=http://localhost:8080
```

## Rodando

```powershell
flutter pub get
flutter run -t lib/main.dart
```

No VS Code, use a configuracao **Sebo Digital App**. Ela aponta sempre para
`lib/main.dart`, mesmo que `test/widget_test.dart` esteja aberto.

## Conta demo

```text
E-mail: guest@exemplo.com
Senha: guest123
```

## Funcionalidades

### v0.3

- GitHub Action de release que compila APK em tags `v*`
- Publicacao automatica do APK como asset da GitHub Release
- Artefato do APK disponivel tambem no workflow run

### v0.2

- Tema escuro com preferencia persistida no dispositivo
- Ajustes de contraste em chips, cards, etiquetas e paineis
- Carrosseis horizontais com arraste por toque/mouse e botoes de avanco

### v0.1

- Catalogo conectado a API existente
- Busca, categorias, filtros e ordenacao
- Detalhes do livro e ofertas
- Carrinho persistido localmente
- Login, cadastro e conta demo
- Checkout demonstrativo enviando pedidos para `/api/pedidos`
- Historico de compras e rastreamento

## Versao

Versao atual:

```text
0.3.0+3
```

Tag Git atual:

```text
v0.3
```
