import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../providers/providers.dart';

class ItemNotifier extends AsyncNotifier<List<Item>> {
  @override
  Future<List<Item>> build() async {
    return ref.read(itemRepositoryProvider).getAllItems();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(itemRepositoryProvider).getAllItems());
  }
}
