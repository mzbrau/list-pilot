import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/item_detail/item_detail_screen.dart';
import '../features/lists/lists_overview_screen.dart';
import '../features/shopping_list/shopping_list_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ListsOverviewScreen(),
      ),
      GoRoute(
        path: '/list/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ShoppingListScreen(listId: id);
        },
        routes: [
          GoRoute(
            path: 'item/:itemId',
            builder: (context, state) {
              final listId = int.parse(state.pathParameters['id']!);
              final itemId = int.parse(state.pathParameters['itemId']!);
              return ItemDetailScreen(listId: listId, itemId: itemId);
            },
          ),
        ],
      ),
    ],
  );
});
