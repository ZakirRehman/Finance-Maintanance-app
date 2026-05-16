import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/business_providers.dart';
import '../../data/models/business_models.dart';
import 'widgets/add_task_sheet.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

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
              errorBuilder: (context, error, stackTrace) => Icon(Icons.check_circle_outline, color: AppColors.luxuryGold, size: 20.w),
            ),
            SizedBox(width: 8.w),
            Text(
              'TASKS',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.luxuryGold, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) return _buildEmptyState();
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: tasks.length,
            itemBuilder: (context, index) => _buildTaskCard(context, ref, tasks[index]),
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
            builder: (context) => const AddTaskSheet(),
          );
        },
        backgroundColor: AppColors.luxuryGold,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, TaskModel task) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: GestureDetector(
          onTap: () async {
            final updated = TaskModel(
              id: task.id,
              userId: task.userId,
              title: task.title,
              isCompleted: !task.isCompleted,
              dueDate: task.dueDate,
              createdAt: task.createdAt,
            );
            await ref.read(businessRepositoryProvider).updateTask(updated);
            ref.invalidate(tasksProvider);
          },
          child: Icon(
            task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: task.isCompleted ? AppColors.luxuryGold : AppColors.textSecondary.withOpacity(0.3),
            size: 24.w,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_horiz, size: 18.w, color: AppColors.textSecondary.withOpacity(0.5)),
          onSelected: (value) async {
            if (value == 'edit') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddTaskSheet(task: task),
              );
            } else if (value == 'remove') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Remove Task?'),
                  content: const Text('Are you sure you want to delete this task?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('REMOVE', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(businessRepositoryProvider).deleteItem('tasks', task.id);
                ref.invalidate(tasksProvider);
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
            const PopupMenuItem(value: 'remove', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Remove', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    ).animate().fade().slideY(begin: 0.1, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 48.w, color: AppColors.textSecondary.withOpacity(0.2)),
          SizedBox(height: 12.h),
          Text('All caught up!', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
