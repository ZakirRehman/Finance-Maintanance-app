import 'package:fpdart/fpdart.dart';
import '../../data/models/order_model.dart';

abstract class OrdersRepository {
  Future<Either<String, List<OrderModel>>> getOrders();
  Future<Either<String, OrderModel>> createOrder(OrderModel order);
  Future<Either<String, OrderModel>> updateOrder(OrderModel order);
  Future<Either<String, void>> deleteOrder(String id);
}
