import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';
import '../partials/drawer.dart';
import '../partials/top_bar.dart';
import '../providers/providers.dart';
import 'dialogs/recipe_picker_dialog.dart';

class WeekPage extends ConsumerWidget {
  const WeekPage({super.key});

  static const List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  String _formatDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  void _changeWeek(WidgetRef ref, int days) {
    final current = ref.read(selectedWeekProvider);
    ref.read(selectedWeekProvider.notifier).state = current.add(
      Duration(days: days),
    );
  }

  Future<void> _addRecipe(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    String mealType,
  ) async {
    final recipe = await showDialog<Recipe>(
      context: context,
      builder: (context) => const RecipePickerDialog(),
    );

    if (recipe != null) {
      await ref
          .read(mealPlanProvider.notifier)
          .addRecipeToMeal(date: date, mealType: mealType, recipeId: recipe.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedWeek = ref.watch(selectedWeekProvider);
    final mealPlanAsync = ref.watch(mealPlanProvider);

    return Scaffold(
      appBar: TopBarPartial(
        title: 'Week of ${_formatDate(selectedWeek)}',
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeWeek(ref, -7),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeWeek(ref, 7),
          ),
        ],
      ),
      drawer: DrawerPartial(currentPage: 'meal_plan_page'),
      body: mealPlanAsync.when(
        data: (entries) {
          return ListView.builder(
            itemCount: 7,
            itemBuilder: (context, index) {
              final dayDate = selectedWeek.add(Duration(days: index));
              final dayEntries = entries
                  .where((e) => DateUtils.isSameDay(e.date, dayDate))
                  .toList();

              return _DayCard(
                date: dayDate,
                formattedDate: _formatDate(dayDate),
                entries: dayEntries,
                mealTypes: mealTypes,
                onAddRecipe: (mealType) =>
                    _addRecipe(context, ref, dayDate, mealType),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime date;
  final String formattedDate;
  final List<MealPlanEntryModel> entries;
  final List<String> mealTypes;
  final Function(String) onAddRecipe;

  const _DayCard({
    required this.date,
    required this.formattedDate,
    required this.entries,
    required this.mealTypes,
    required this.onAddRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: isToday ? Theme.of(context).colorScheme.primaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: isToday,
        title: Text(
          formattedDate,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: isToday ? FontWeight.bold : null,
            color: isToday
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : null,
          ),
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 8.0,
        ),
        children: [
          Divider(
            color: isToday
                ? Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(50)
                : Theme.of(context).colorScheme.secondaryContainer,
          ),
          ...mealTypes.map((type) {
            final entry = entries.where((e) => e.mealType == type).firstOrNull;
            return _MealTypeSection(
              type: type,
              entry: entry,
              onAdd: () => onAddRecipe(type),
            );
          }),
        ],
      ),
    );
  }
}

class _MealTypeSection extends ConsumerWidget {
  final String type;
  final MealPlanEntryModel? entry;
  final VoidCallback onAdd;

  const _MealTypeSection({required this.type, this.entry, required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              if (entry == null || entry!.recipes.isEmpty)
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: onAdd,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          if (entry != null)
            ...entry!.recipes.asMap().entries.map((e) {
              final index = e.key;
              final recipe = e.value;
              return Padding(
                padding: EdgeInsets.only(left: index > 0 ? 16.0 : 0.0),
                child: _RecipeItem(recipe: recipe),
              );
            }),
          if (entry != null && entry!.recipes.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Side'),
                onPressed: onAdd,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecipeItem extends ConsumerWidget {
  final MealPlanEntryRecipeModel recipe;

  const _RecipeItem({required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(recipe.recipe.name),
      subtitle: Text(
        '${recipe.servings} serving${recipe.servings == 1 ? "" : "s"}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: () {
              if (recipe.servings > 1) {
                ref
                    .read(mealPlanProvider.notifier)
                    .updateServings(recipe.id, recipe.servings - 1);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () {
              ref
                  .read(mealPlanProvider.notifier)
                  .updateServings(recipe.id, recipe.servings + 1);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            onPressed: () {
              ref
                  .read(mealPlanProvider.notifier)
                  .removeRecipeFromMeal(recipe.id);
            },
          ),
        ],
      ),
    );
  }
}
