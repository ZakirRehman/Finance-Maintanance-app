import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/inventory_model.dart';
import '../../../providers/business_providers.dart';

class AddInventorySheet extends ConsumerStatefulWidget {
  final InventoryModel? item;

  const AddInventorySheet({super.key, this.item});

  @override
  ConsumerState<AddInventorySheet> createState() => _AddInventorySheetState();
}

class _AddInventorySheetState extends ConsumerState<AddInventorySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _costController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.itemName);
    _quantityController = TextEditingController(text: widget.item?.quantity.toString());
    _costController = TextEditingController(text: widget.item?.costPerUnit.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final itemData = InventoryModel(
      id: widget.item?.id ?? '',
      userId: widget.item?.userId ?? '',
      itemName: _nameController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      costPerUnit: double.parse(_costController.text.trim()),
      updatedAt: DateTime.now(),
    );

    final result = widget.item == null 
        ? await ref.read(inventoryRepositoryProvider).addInventoryItem(itemData)
        : await ref.read(inventoryRepositoryProvider).updateInventoryItem(itemData);

    if (mounted) {
      setState(() => _isSubmitting = false);
      result.fold(
        (error) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        ),
        (item) {
          ref.invalidate(inventoryProvider);
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Container(
      padding: EdgeInsets.only(
        left: 20.w, 
        right: 20.w, 
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              isEditing ? 'EDIT INVENTORY ITEM' : 'ADD INVENTORY ITEM',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.luxuryGold),
            ),
            SizedBox(height: 24.h),
            _buildTextField(_nameController, 'Item Name', Icons.inventory_2_outlined),
            SizedBox(height: 16.h),
            _buildTextField(_quantityController, 'Quantity', Icons.numbers_outlined, keyboardType: TextInputType.number),
            SizedBox(height: 16.h),
            _buildTextField(_costController, 'Cost Per Unit (PKR)', Icons.payments_outlined, keyboardType: TextInputType.number),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting 
                  ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isEditing ? 'UPDATE ITEM' : 'ADD TO INVENTORY'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 12.sp),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18.w),
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}
