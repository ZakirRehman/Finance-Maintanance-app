import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/business_models.dart';
import '../../../providers/business_providers.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  final TaskModel? task;
  const AddTaskSheet({super.key, this.task});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
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
    final result = widget.task != null
        ? await repo.updateTask(TaskModel(
            id: widget.task!.id,
            userId: widget.task!.userId,
            title: _titleController.text.trim(),
            isCompleted: widget.task!.isCompleted,
            createdAt: widget.task!.createdAt,
          ))
        : await repo.addTask(TaskModel(
            id: '',
            userId: '',
            title: _titleController.text.trim(),
            createdAt: DateTime.now(),
          ));

    if (mounted) {
      setState(() => _isSubmitting = false);
      result.fold(
        (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error))),
        (_) {
          ref.invalidate(tasksProvider);
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
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
            Text(isEditing ? 'EDIT TASK' : 'ADD NEW TASK', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.luxuryGold)),
            SizedBox(height: 20.h),
            TextFormField(
              controller: _titleController,
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                prefixIcon: Icon(Icons.check_circle_outline, size: 20.w),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              autofocus: !isEditing,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _isSubmitting ? null : _submit, child: Text(isEditing ? 'UPDATE TASK' : 'CREATE TASK')),
            ),
          ],
        ),
      ),
    );
  }
}
