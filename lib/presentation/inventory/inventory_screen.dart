import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/business_providers.dart';
import '../../data/models/inventory_model.dart';
import 'widgets/add_inventory_sheet.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 28.h,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.card_giftcard, color: AppColors.luxuryGold, size: 20.w),
            ),
            SizedBox(width: 8.w),
            Text(
              'INVENTORY',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.luxuryGold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: inventoryAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildInventoryCard(context, ref, items[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddInventorySheet(),
          );
        },
        backgroundColor: AppColors.luxuryGold,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, WidgetRef ref, InventoryModel item) {
    final isLowStock = item.quantity <= item.lowStockLimit;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: isLowStock ? Border.all(color: AppColors.error.withOpacity(0.3), width: 1) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: isLowStock ? AppColors.error.withOpacity(0.05) : AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.inventory_2_outlined, 
              color: isLowStock ? AppColors.error : AppColors.luxuryGold, 
              size: 18.w
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(
                  '${item.quantity} units remaining',
                  style: TextStyle(
                    fontSize: 10.sp, 
                    color: isLowStock ? AppColors.error : AppColors.textSecondary
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'PKR ${item.costPerUnit}',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              if (isLowStock)
                Text(
                  'LOW STOCK',
                  style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold, color: AppColors.error),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 18.w, color: AppColors.textSecondary),
            padding: EdgeInsets.zero,
            onSelected: (value) => _handleMenuAction(context, ref, value, item),
            itemBuilder: (context) => [
              _buildMenuItem('edit', Icons.edit_outlined, 'Edit'),
              _buildMenuItem('delete', Icons.delete_outline, 'Remove', isDestructive: true),
            ],
          ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.1, end: 0);
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String label, {bool isDestructive = false}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16.w, color: isDestructive ? Colors.red : AppColors.textPrimary),
          SizedBox(width: 12.w),
          Text(label, style: TextStyle(fontSize: 12.sp, color: isDestructive ? Colors.red : AppColors.textPrimary)),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action, InventoryModel item) {
    switch (action) {
      case 'edit':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AddInventorySheet(item: item),
        );
        break;
      case 'delete':
        _confirmDelete(context, ref, item);
        break;
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, InventoryModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text('Are you sure you want to remove this item from inventory?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              await ref.read(inventoryRepositoryProvider).deleteInventoryItem(item.id);
              ref.invalidate(inventoryProvider);
              Navigator.pop(context);
            },
            child: const Text('REMOVE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_outlined, size: 48.w, color: AppColors.textSecondary.withOpacity(0.2)),
          SizedBox(height: 12.h),
          Text('Inventory is empty', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
