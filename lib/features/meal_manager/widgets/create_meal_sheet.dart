import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';

class CreateMealSheet extends ConsumerWidget {
  const CreateMealSheet({super.key});

  static Future<void> show(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) => const SafeArea(child: CreateMealSheet()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiConfigured = ref.watch(aiConfigProvider).isConfigured;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Create manually'),
          subtitle: const Text('Start with a blank recipe'),
          onTap: () async {
            final router = GoRouter.of(context);
            Navigator.pop(context);
            final meal = await ref.read(mealRepositoryProvider).createMeal(
                  displayName: 'New meal',
                );
            router.push(
              '/meal-manager/${meal.id}',
              extra: true,
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.code_outlined),
          title: const Text('Import from webpage'),
          subtitle: const Text('Extract recipe from page data'),
          onTap: () {
            final router = GoRouter.of(context);
            Navigator.pop(context);
            router.push('/meal-manager/import/extract');
          },
        ),
        if (aiConfigured) ...[
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('Import with AI'),
            subtitle: const Text('Extract recipe using AI'),
            onTap: () {
              final router = GoRouter.of(context);
              Navigator.pop(context);
              router.push('/meal-manager/import');
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Import from photo'),
            subtitle: const Text('Extract recipe from a photo using AI'),
            onTap: () {
              final router = GoRouter.of(context);
              Navigator.pop(context);
              router.push('/meal-manager/import/photo');
            },
          ),
        ],
      ],
    );
  }
}
