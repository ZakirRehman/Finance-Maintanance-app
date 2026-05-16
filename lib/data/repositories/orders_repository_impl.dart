import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/orders_repository.dart';
import '../models/order_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final SupabaseClient _supabase;

  OrdersRepositoryImpl(this._supabase);

  @override
  Future<Either<String, List<OrderModel>>> getOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false);
      
      final orders = (response as List).map((json) => OrderModel.fromJson(json)).toList();
      return Right(orders);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, OrderModel>> createOrder(OrderModel order) async {
    try {
      final data = order.toJson();
      data['user_id'] = _supabase.auth.currentUser!.id;
      
      final response = await _supabase
          .from('orders')
          .insert(data)
          .select()
          .single();
      
      final newOrder = OrderModel.fromJson(response);

      // Autonomous Task Tracking: Create a task for the new order
      await _supabase.from('tasks').insert({
        'user_id': _supabase.auth.currentUser!.id,
        'title': 'Prepare ${newOrder.orderType} for ${newOrder.customerName}',
        'is_completed': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return Right(newOrder);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, OrderModel>> updateOrder(OrderModel order) async {
    try {
      final response = await _supabase
          .from('orders')
          .update(order.toJson())
          .eq('id', order.id)
          .select()
          .single();
      
      return Right(OrderModel.fromJson(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteOrder(String id) async {
    try {
      await _supabase.from('orders').delete().eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
