import 'package:fpdart/fpdart.dart';
import '../../data/models/inventory_model.dart';

abstract class InventoryRepository {
  Future<Either<String, List<InventoryModel>>> getInventory();
  Future<Either<String, InventoryModel>> addInventoryItem(InventoryModel item);
  Future<Either<String, InventoryModel>> updateInventoryItem(InventoryModel item);
  Future<Either<String, void>> deleteInventoryItem(String id);
}
