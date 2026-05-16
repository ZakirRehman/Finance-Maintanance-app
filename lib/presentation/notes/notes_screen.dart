import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/business_providers.dart';
import '../../data/models/business_models.dart';
import 'widgets/add_note_sheet.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

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
              errorBuilder: (context, error, stackTrace) => Icon(Icons.note_alt_outlined, color: AppColors.luxuryGold, size: 20.w),
            ),
            SizedBox(width: 8.w),
            Text(
              'NOTES',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.luxuryGold, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) return _buildEmptyState();
          return MasonryGridView.count(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            crossAxisCount: 2,
            mainAxisSpacing: 12.w,
            crossAxisSpacing: 12.w,
            itemCount: notes.length,
            itemBuilder: (context, index) => _buildNoteCard(context, ref, notes[index]),
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
            builder: (context) => const AddNoteSheet(),
          );
        },
        backgroundColor: AppColors.luxuryGold,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, WidgetRef ref, NoteModel note) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  note.title ?? 'Untitled',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_horiz, size: 16.w, color: AppColors.textSecondary.withOpacity(0.5)),
                onSelected: (value) async {
                  if (value == 'edit') {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AddNoteSheet(note: note),
                    );
                  } else if (value == 'remove') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('Delete Note?'),
                        content: const Text('Are you sure you want to delete this note?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(businessRepositoryProvider).deleteItem('notes', note.id);
                      ref.invalidate(notesProvider);
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 14), SizedBox(width: 8), Text('Edit', style: TextStyle(fontSize: 12))])),
                  const PopupMenuItem(value: 'remove', child: Row(children: [Icon(Icons.delete, size: 14, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12))])),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            note.content,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, height: 1.5),
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fade().scale(duration: 400.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note_outlined, size: 48.w, color: AppColors.textSecondary.withOpacity(0.2)),
          SizedBox(height: 12.h),
          Text('Capture your ideas', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
