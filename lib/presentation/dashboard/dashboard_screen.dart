import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_providers.dart';
import '../../providers/business_providers.dart';
import '../../data/models/order_model.dart';
import '../../data/models/inventory_model.dart';
import '../../data/models/business_models.dart';
import '../orders/widgets/add_order_sheet.dart';
import '../tasks/widgets/add_task_sheet.dart';
import '../inventory/widgets/add_inventory_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userName = user?.userMetadata?['full_name'] ?? 'Owner';

    final ordersAsync = ref.watch(ordersProvider);
    final inventoryAsync = ref.watch(inventoryProvider);
    final financeAsync = ref.watch(financeProvider);

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
              height: 32.h,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.card_giftcard, color: AppColors.luxuryGold, size: 24.w),
            ),
            SizedBox(width: 10.w),
            Text(
              "INBISAT's",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.luxuryGold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: AppColors.textPrimary, size: 20.w),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Text(
                'Good Morning,',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 24.h),
              _buildStatsGrid(ordersAsync, inventoryAsync, financeAsync),
              SizedBox(height: 24.h),
              _buildSectionTitle('QUICK ACTIONS'),
              SizedBox(height: 12.h),
              _buildQuickActions(context),
              SizedBox(height: 24.h),
              _buildSectionTitle('RECENT ORDERS'),
              SizedBox(height: 12.h),
              _buildRecentOrders(ordersAsync),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      ),
    ).animate().fade(duration: 600.ms);
  }

  Widget _buildStatsGrid(
    AsyncValue<List<OrderModel>> ordersAsync,
    AsyncValue<List<InventoryModel>> inventoryAsync,
    AsyncValue<List<FinanceModel>> financeAsync,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12.w,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.8,
      children: [
        ordersAsync.when(
          data: (orders) => _buildStatCard('Total Orders', orders.length.toString(), Icons.shopping_bag_outlined),
          loading: () => _buildStatCard('Total Orders', '...', Icons.shopping_bag_outlined),
          error: (_, __) => _buildStatCard('Total Orders', 'Err', Icons.shopping_bag_outlined),
        ),
        ordersAsync.when(
          data: (orders) => _buildStatCard('Pending', orders.where((o) => o.status == 'Pending').length.toString(), Icons.pending_actions_outlined),
          loading: () => _buildStatCard('Pending', '...', Icons.pending_actions_outlined),
          error: (_, __) => _buildStatCard('Pending', 'Err', Icons.pending_actions_outlined),
        ),
        financeAsync.when(
          data: (transactions) {
            double income = transactions.where((t) => t.type == 'Income').fold(0, (sum, item) => sum + item.amount);
            double expense = transactions.where((t) => t.type == 'Expense').fold(0, (sum, item) => sum + item.amount);
            return _buildStatCard('Balance', 'PKR ${(income - expense).toStringAsFixed(0)}', Icons.payments_outlined);
          },
          loading: () => _buildStatCard('Balance', '...', Icons.payments_outlined),
          error: (_, __) => _buildStatCard('Balance', 'Err', Icons.payments_outlined),
        ),
        inventoryAsync.when(
          data: (items) {
            final lowStockCount = items.where((i) => i.quantity <= i.lowStockLimit).length;
            return _buildStatCard('Low Stock', lowStockCount.toString(), Icons.warning_amber_outlined, isWarning: lowStockCount > 0);
          },
          loading: () => _buildStatCard('Low Stock', '...', Icons.warning_amber_outlined),
          error: (_, __) => _buildStatCard('Low Stock', 'Err', Icons.warning_amber_outlined),
        ),
      ],
    ).animate().fade(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildStatCard(String title, String value, IconData icon, {bool isWarning = false}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: (isWarning ? AppColors.error : AppColors.luxuryGold).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: isWarning ? AppColors.error : AppColors.luxuryGold, size: 16.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionItem(context, 'Add Order', Icons.add_shopping_cart, AppColors.luxuryGold, () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddOrderSheet(),
          );
        }),
        _buildActionItem(context, 'Add Task', Icons.add_task, Colors.blueAccent, () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTaskSheet(),
          );
        }),
        _buildActionItem(context, 'Add Stock', Icons.add_box_outlined, Colors.orangeAccent, () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddInventorySheet(),
          );
        }),
        _buildActionItem(context, 'Finances', Icons.analytics_outlined, Colors.teal, () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Financial reports are auto-tracked!')));
        }),
      ],
    ).animate().fade(delay: 400.ms, duration: 600.ms);
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70.w,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 20.w),
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(AsyncValue<List<OrderModel>> ordersAsync) {
    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return Center(child: Text('No recent orders', style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)));
        }
        final recent = orders.take(5).toList();
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recent.length,
          itemBuilder: (context, index) {
            final order = recent[index];
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.divider.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.card_giftcard, color: AppColors.luxuryGold, size: 18.w),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'PKR ${order.totalPrice} • ${order.status}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary.withOpacity(0.5), size: 16.w),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading orders')),
    ).animate().fade(delay: 600.ms, duration: 600.ms);
  }
}
