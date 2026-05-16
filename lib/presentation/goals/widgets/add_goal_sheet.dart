import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/business_models.dart';
import '../../../providers/business_providers.dart';

class AddGoalSheet extends ConsumerStatefulWidget {
  final GoalModel? goal;
  const AddGoalSheet({super.key, this.goal});

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late String _category;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title);
    _category = widget.goal?.category ?? 'Goal';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final repo = ref.read(businessRepositoryProvider);
    final result = widget.goal != null
        ? await repo.updateGoal(GoalModel(
            id: widget.goal!.id,
            userId: widget.goal!.userId,
            title: _titleController.text.trim(),
            category: _category,
            isReached: widget.goal!.isReached,
            targetDate: widget.goal!.targetDate,
          ))
        : await repo.addGoal(GoalModel(
            id: '',
            userId: '',
            title: _titleController.text.trim(),
            category: _category,
          ));

    if (mounted) {
      setState(() => _isSubmitting = false);
      result.fold(
        (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error))),
        (_) {
          ref.invalidate(goalsProvider);
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goal != null;
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: MediaQuery.of(context).viewInsets.bottom + 20.h),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2.r)))),
            SizedBox(height: 20.h),
            Text(isEditing ? 'EDIT GOAL' : 'SET A GOAL OR WISH', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.luxuryGold)),
            SizedBox(height: 20.h),
            Row(
              children: [
                _buildTypeButton('Goal', Icons.emoji_events_outlined),
                SizedBox(width: 12.w),
                _buildTypeButton('Wishlist', Icons.auto_awesome_outlined),
              ],
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: _titleController,
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'What do you want to achieve?',
                prefixIcon: Icon(_category == 'Goal' ? Icons.emoji_events_outlined : Icons.auto_awesome_outlined, size: 20.w),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _isSubmitting ? null : _submit, child: Text(isEditing ? 'UPDATE' : 'ADD TO LIST')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String cat, IconData icon) {
    final isSelected = _category == cat;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _category = cat),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.luxuryGold : AppColors.luxuryGold.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.w, color: isSelected ? Colors.white : AppColors.luxuryGold),
              SizedBox(width: 8.w),
              Text(cat, style: TextStyle(color: isSelected ? Colors.white : AppColors.luxuryGold, fontWeight: FontWeight.bold, fontSize: 12.sp)),
            ],
          ),
        ),
      ),
    );
  }
}
