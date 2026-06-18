import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';

class TakeAwayMenuCard extends ConsumerWidget {
  const TakeAwayMenuCard({
    super.key,
    required this.listId,
    required this.menu,
  });

  final int listId;
  final TakeAwayMenu menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orderAsync = ref.watch(takeAwayOrderProvider(menu.id));
    final lineCount = orderAsync.valueOrNull?.lines.length ?? 0;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/take-away/$listId/menu/${menu.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.restaurant_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.restaurantName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (menu.location != null && menu.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        menu.location!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (lineCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Badge(
                    label: Text('$lineCount'),
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
