import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../models/inventory_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final SupabaseClient _supabase;

  InventoryRepositoryImpl(this._supabase);

  @override
  Future<Either<String, List<InventoryModel>>> getInventory() async {
    try {
      final response = await _supabase
          .from('inventory')
          .select()
          .order('item_name', ascending: true);
      
      final items = (response as List).map((json) => InventoryModel.fromJson(json)).toList();
      return Right(items);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, InventoryModel>> addInventoryItem(InventoryModel item) async {
    try {
      final data = item.toJson();
      data['user_id'] = _supabase.auth.currentUser!.id;
      
      final response = await _supabase
          .from('inventory')
          .insert(data)
          .select()
          .single();
      
      return Right(InventoryModel.fromJson(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, InventoryModel>> updateInventoryItem(InventoryModel item) async {
    try {
      final response = await _supabase
          .from('inventory')
          .update(item.toJson())
          .eq('id', item.id)
          .select()
          .single();
      
      final updatedItem = InventoryModel.fromJson(response);

      // Autonomous Task Tracking: Create a task if stock is low
      if (updatedItem.quantity <= updatedItem.lowStockLimit) {
        await _supabase.from('tasks').insert({
          'user_id': _supabase.auth.currentUser!.id,
          'title': 'RESTOCK REQUIRED: ${updatedItem.itemName}',
          'is_completed': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      
      return Right(updatedItem);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteInventoryItem(String id) async {
    try {
      await _supabase.from('inventory').delete().eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
