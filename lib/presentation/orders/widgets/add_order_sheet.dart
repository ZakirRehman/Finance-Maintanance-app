import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/business_providers.dart';

class AddOrderSheet extends ConsumerStatefulWidget {
  final OrderModel? order;

  const AddOrderSheet({super.key, this.order});

  @override
  ConsumerState<AddOrderSheet> createState() => _AddOrderSheetState();
}

class _AddOrderSheetState extends ConsumerState<AddOrderSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _priceController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.order?.customerName);
    _typeController = TextEditingController(text: widget.order?.orderType);
    _priceController = TextEditingController(text: widget.order?.totalPrice.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final orderData = OrderModel(
      id: widget.order?.id ?? '',
      userId: widget.order?.userId ?? '',
      customerName: _nameController.text.trim(),
      orderType: _typeController.text.trim(),
      totalPrice: double.parse(_priceController.text.trim()),
      remainingPayment: widget.order?.remainingPayment ?? double.parse(_priceController.text.trim()),
      status: widget.order?.status ?? 'Pending',
      createdAt: widget.order?.createdAt ?? DateTime.now(),
    );

    final result = widget.order == null 
        ? await ref.read(ordersRepositoryProvider).createOrder(orderData)
        : await ref.read(ordersRepositoryProvider).updateOrder(orderData);

    if (mounted) {
      setState(() => _isSubmitting = false);
      result.fold(
        (error) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        ),
        (order) {
          ref.invalidate(ordersProvider);
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.order != null;

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
              isEditing ? 'EDIT ORDER' : 'NEW ORDER',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.luxuryGold),
            ),
            SizedBox(height: 24.h),
            _buildTextField(_nameController, 'Customer Name', Icons.person_outline),
            SizedBox(height: 16.h),
            _buildTextField(_typeController, 'Order Type (e.g. Bouquet)', Icons.card_giftcard),
            SizedBox(height: 16.h),
            _buildTextField(_priceController, 'Total Price (PKR)', Icons.payments_outlined, keyboardType: TextInputType.number),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting 
                  ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isEditing ? 'UPDATE ORDER' : 'CREATE ORDER'),
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
