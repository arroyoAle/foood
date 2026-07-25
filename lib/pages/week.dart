import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_plan.dart';
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
    final result = await showDialog<RecipePickerResult>(
      context: context,
      builder: (context) => const RecipePickerDialog(),
    );

    if (result != null) {
      await ref
          .read(mealPlanProvider.notifier)
          .addMealWithSides(
            date: date,
            mealType: mealType,
            mainRecipeId: result.main.id,
            mainServings: 1,
            sides: result.sides
                .map((s) => (recipeId: s.id, servings: 1))
                .toList(),
          );
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
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        children: [
          ...mealTypes.map((type) {
            final entry = entries.where((e) => e.mealType == type).firstOrNull;
            return _MealTypeSection(
              type: type,
              entry: entry,
              isToday: isToday,
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
  final bool isToday;
  final VoidCallback onAdd;

  const _MealTypeSection({
    required this.type,
    this.entry,
    required this.isToday,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 0,
      color: isToday
          ? Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100)
          : Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: onAdd,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Add Meal',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            if (entry != null && entry!.recipes.isNotEmpty) ...[
              const Divider(height: 24),
              ...entry!.recipes.map((main) => _MainMealBlock(main: main)),
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No meals planned',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MainMealBlock extends StatelessWidget {
  final MealPlanEntryRecipeModel main;

  const _MainMealBlock({required this.main});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecipeItem(recipe: main, isMain: true),
        if (main.sides.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 8.0, top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right,
                      size: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SIDES',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ...main.sides.map((side) => _RecipeItem(recipe: side)),
              ],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _RecipeItem extends ConsumerWidget {
  final MealPlanEntryRecipeModel recipe;
  final bool isMain;

  const _RecipeItem({required this.recipe, this.isMain = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: !isMain,
      title: Text(
        recipe.recipe.name,
        style: TextStyle(
          fontWeight: isMain ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        '${recipe.servings} serving${recipe.servings == 1 ? "" : "s"}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 18),
            onPressed: () {
              if (recipe.servings > 1) {
                ref
                    .read(mealPlanProvider.notifier)
                    .updateServings(recipe.id, recipe.servings - 1);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 18),
            onPressed: () {
              ref
                  .read(mealPlanProvider.notifier)
                  .updateServings(recipe.id, recipe.servings + 1);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
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
