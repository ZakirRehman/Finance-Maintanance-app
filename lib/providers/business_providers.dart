import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/orders_repository_impl.dart';
import '../data/repositories/inventory_repository_impl.dart';
import '../data/repositories/business_repository_impl.dart';
import '../domain/repositories/orders_repository.dart';
import '../domain/repositories/inventory_repository.dart';
import '../data/models/order_model.dart';
import '../data/models/inventory_model.dart';
import '../data/models/business_models.dart';
import 'auth_providers.dart';

// Repositories
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return OrdersRepositoryImpl(supabase);
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return InventoryRepositoryImpl(supabase);
});

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return BusinessRepository(supabase);
});

// Data Providers
final ordersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final result = await repository.getOrders();
  return result.fold((error) => throw error, (orders) => orders);
});

final inventoryProvider = FutureProvider<List<InventoryModel>>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  final result = await repository.getInventory();
  return result.fold((error) => throw error, (items) => items);
});

final financeProvider = FutureProvider<List<FinanceModel>>((ref) async {
  final repository = ref.watch(businessRepositoryProvider);
  final result = await repository.getFinances();
  return result.fold((error) => throw error, (items) => items);
});

final tasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(businessRepositoryProvider);
  final result = await repository.getTasks();
  return result.fold((error) => throw error, (items) => items);
});

final notesProvider = FutureProvider<List<NoteModel>>((ref) async {
  final repository = ref.watch(businessRepositoryProvider);
  final result = await repository.getNotes();
  return result.fold((error) => throw error, (items) => items);
});

final goalsProvider = FutureProvider<List<GoalModel>>((ref) async {
  final repository = ref.watch(businessRepositoryProvider);
  final result = await repository.getGoals();
  return result.fold((error) => throw error, (items) => items);
});
