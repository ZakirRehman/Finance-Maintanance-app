import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/business_models.dart';
import '../../../providers/business_providers.dart';

class AddNoteSheet extends ConsumerStatefulWidget {
  final NoteModel? note;
  const AddNoteSheet({super.key, this.note});

  @override
  ConsumerState<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends ConsumerState<AddNoteSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _contentController = TextEditingController(text: widget.note?.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final repo = ref.read(businessRepositoryProvider);
    final result = widget.note != null
        ? await repo.updateNote(NoteModel(
            id: widget.note!.id,
            userId: widget.note!.userId,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            colorHex: widget.note!.colorHex,
            createdAt: widget.note!.createdAt,
          ))
        : await repo.addNote(NoteModel(
            id: '',
            userId: '',
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            createdAt: DateTime.now(),
          ));

    if (mounted) {
      setState(() => _isSubmitting = false);
      result.fold(
        (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error))),
        (_) {
          ref.invalidate(notesProvider);
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
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
            Text(isEditing ? 'EDIT NOTE' : 'CAPTURE NOTE', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.luxuryGold)),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _titleController,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(hintText: 'Title (Optional)', border: InputBorder.none, prefixIcon: null),
            ),
            TextFormField(
              controller: _contentController,
              style: TextStyle(fontSize: 12.sp),
              decoration: const InputDecoration(hintText: 'Start writing...', border: InputBorder.none, prefixIcon: null),
              maxLines: 8,
              validator: (value) => value == null || value.isEmpty ? 'Content cannot be empty' : null,
              autofocus: !isEditing,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _isSubmitting ? null : _submit, child: Text(isEditing ? 'UPDATE NOTE' : 'SAVE NOTE')),
            ),
          ],
        ),
      ),
    );
  }
}
