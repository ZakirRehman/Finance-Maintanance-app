import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/business_providers.dart';
import '../../data/models/business_models.dart';
import 'widgets/add_goal_sheet.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

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
              errorBuilder: (context, error, stackTrace) => Icon(Icons.auto_awesome_outlined, color: AppColors.luxuryGold, size: 20.w),
            ),
            SizedBox(width: 8.w),
            Text(
              'GOALS & WISHES',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.luxuryGold, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) return _buildEmptyState();
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: goals.length,
            itemBuilder: (context, index) => _buildGoalCard(context, ref, goals[index]),
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
            builder: (context) => const AddGoalSheet(),
          );
        },
        backgroundColor: AppColors.luxuryGold,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, WidgetRef ref, GoalModel goal) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: goal.isReached ? Colors.green.withOpacity(0.3) : AppColors.divider.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final updated = GoalModel(
                id: goal.id,
                userId: goal.userId,
                title: goal.title,
                category: goal.category,
                isReached: !goal.isReached,
                targetDate: goal.targetDate,
              );
              await ref.read(businessRepositoryProvider).updateGoal(updated);
              ref.invalidate(goalsProvider);
            },
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: (goal.isReached ? Colors.green : AppColors.luxuryGold).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                goal.isReached ? Icons.stars : Icons.emoji_events_outlined, 
                color: goal.isReached ? Colors.green : AppColors.luxuryGold, 
                size: 20.w
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 13.sp, 
                    fontWeight: FontWeight.w600,
                    decoration: goal.isReached ? TextDecoration.lineThrough : null,
                    color: goal.isReached ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
                if (goal.category != null)
                  Text(
                    goal.category!.toUpperCase(),
                    style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: AppColors.luxuryGold.withOpacity(0.7), letterSpacing: 0.5),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 18.w, color: AppColors.textSecondary.withOpacity(0.5)),
            onSelected: (value) async {
              if (value == 'edit') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddGoalSheet(goal: goal),
                );
              } else if (value == 'remove') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Remove Goal?'),
                    content: const Text('Are you sure you want to delete this goal?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('REMOVE', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(businessRepositoryProvider).deleteItem('goals', goal.id);
                  ref.invalidate(goalsProvider);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
              const PopupMenuItem(value: 'remove', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Remove', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.1, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_outlined, size: 48.w, color: AppColors.textSecondary.withOpacity(0.2)),
          SizedBox(height: 12.h),
          Text('Dream big, set your goals', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
