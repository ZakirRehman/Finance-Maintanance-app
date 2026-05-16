import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/business_providers.dart';
import '../../data/models/business_models.dart';
import 'widgets/add_transaction_sheet.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              height: 28.h,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.payments_outlined, color: AppColors.luxuryGold, size: 20.w),
            ),
            SizedBox(width: 8.w),
            Text(
              'FINANCE',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.luxuryGold, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
      body: financeAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) return _buildEmptyState();
          return Column(
            children: [
              _buildSummaryCard(transactions),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) => _buildTransactionCard(transactions[index]),
                ),
              ),
            ],
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
            builder: (context) => const AddTransactionSheet(),
          );
        },
        backgroundColor: AppColors.luxuryGold,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(List<FinanceModel> transactions) {
    double income = transactions.where((t) => t.type == 'Income').fold(0, (sum, item) => sum + item.amount);
    double expense = transactions.where((t) => t.type == 'Expense').fold(0, (sum, item) => sum + item.amount);
    double balance = income - expense;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.luxuryGold,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: AppColors.luxuryGold.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Text('Total Balance', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.sp)),
          SizedBox(height: 4.h),
          Text('PKR ${balance.toStringAsFixed(0)}', style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Income', income, Icons.arrow_downward),
              Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
              _buildSummaryItem('Expense', expense, Icons.arrow_upward),
            ],
          ),
        ],
      ),
    ).animate().fade().scale(duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildSummaryItem(String label, double amount, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 16.w),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10.sp)),
            Text('PKR ${amount.toStringAsFixed(0)}', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionCard(FinanceModel transaction) {
    final isIncome = transaction.type == 'Income';
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: (isIncome ? Colors.green : Colors.red).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.add : Icons.remove, 
              color: isIncome ? Colors.green : Colors.red, 
              size: 16.w
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.category ?? 'General', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                Text(transaction.description ?? '', style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} PKR ${transaction.amount}',
            style: TextStyle(
              fontSize: 12.sp, 
              fontWeight: FontWeight.bold, 
              color: isIncome ? Colors.green : Colors.red
            ),
          ),
        ],
      ),
    ).animate().fade().slideX(begin: 0.05, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 48.w, color: AppColors.textSecondary.withOpacity(0.2)),
          SizedBox(height: 12.h),
          Text('No transactions yet', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
