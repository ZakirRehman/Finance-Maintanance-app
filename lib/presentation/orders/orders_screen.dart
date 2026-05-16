import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/business_providers.dart';
import '../../data/models/order_model.dart';
import 'widgets/add_order_sheet.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String _selectedStatus = 'All';
  final List<String> _statuses = ['All', 'Pending', 'In Progress', 'Ready', 'Delivered', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

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
              'ORDERS',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.luxuryGold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.search, size: 18.w, color: AppColors.textPrimary), onPressed: () {}),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final filteredOrders = _selectedStatus == 'All' 
                    ? orders 
                    : orders.where((o) => o.status == _selectedStatus).toList();
                
                if (filteredOrders.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) => _buildOrderCard(filteredOrders[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddOrderSheet(),
          );
        },
        backgroundColor: AppColors.luxuryGold,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _statuses.length,
        itemBuilder: (context, index) {
          final status = _statuses[index];
          final isSelected = _selectedStatus == status;
          return GestureDetector(
            onTap: () => setState(() => _selectedStatus = status),
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.luxuryGold : AppColors.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: isSelected ? AppColors.luxuryGold : AppColors.divider.withOpacity(0.5)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.shopping_basket_outlined, color: AppColors.luxuryGold, size: 18.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(
                  '${order.orderType} • PKR ${order.totalPrice}',
                  style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          _buildStatusBadge(order.status),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 18.w, color: AppColors.textSecondary),
            padding: EdgeInsets.zero,
            onSelected: (value) => _handleMenuAction(value, order),
            itemBuilder: (context) => [
              _buildMenuItem('edit', Icons.edit_outlined, 'Edit'),
              _buildMenuItem('status', Icons.sync_outlined, 'Change Status'),
              _buildMenuItem('delete', Icons.delete_outline, 'Remove', isDestructive: true),
            ],
          ),
        ],
      ),
    ).animate().fade().slideX(begin: 0.05, end: 0);
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold, color: _getStatusColor(status)),
      ),
    );
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

  void _handleMenuAction(String action, OrderModel order) {
    switch (action) {
      case 'edit':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AddOrderSheet(order: order),
        );
        break;
      case 'status':
        _showStatusPicker(order);
        break;
      case 'delete':
        _confirmDelete(order);
        break;
    }
  }

  void _showStatusPicker(OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statuses.where((s) => s != 'All').map((status) => ListTile(
            title: Text(status, style: TextStyle(fontSize: 14.sp)),
            onTap: () async {
              final updatedOrder = OrderModel(
                id: order.id,
                userId: order.userId,
                customerName: order.customerName,
                orderType: order.orderType,
                totalPrice: order.totalPrice,
                remainingPayment: order.remainingPayment,
                status: status,
                createdAt: order.createdAt,
              );
              await ref.read(ordersRepositoryProvider).updateOrder(updatedOrder);
              ref.invalidate(ordersProvider);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _confirmDelete(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Order'),
        content: const Text('Are you sure you want to remove this order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              await ref.read(ordersRepositoryProvider).deleteOrder(order.id);
              ref.invalidate(ordersProvider);
              Navigator.pop(context);
            },
            child: const Text('REMOVE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'In Progress': return Colors.blue;
      case 'Ready': return Colors.green;
      case 'Delivered': return AppColors.luxuryGold;
      case 'Cancelled': return Colors.red;
      default: return AppColors.textSecondary;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48.w, color: AppColors.textSecondary.withOpacity(0.2)),
          SizedBox(height: 12.h),
          Text('No orders found', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
