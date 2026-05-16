import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/business_models.dart';
import '../../../providers/business_providers.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String _type = 'Income';
  String _category = 'Sales';
  bool _isSubmitting = false;

  final List<String> _categories = ['Sales', 'Supplies', 'Rent', 'Marketing', 'Salary', 'Other'];

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final transaction = FinanceModel(
      id: '',
      userId: '',
      type: _type,
      category: _category,
      amount: double.parse(_amountController.text),
      description: _descController.text,
      date: DateTime.now(),
    );

    final result = await ref.read(businessRepositoryProvider).addFinance(transaction);

    if (mounted) {
      setState(() => _isSubmitting = false);
      result.fold(
        (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error))),
        (_) {
          ref.invalidate(financeProvider);
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text('ADD TRANSACTION', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.luxuryGold)),
            SizedBox(height: 20.h),
            Row(
              children: [
                _buildTypeButton('Income', Colors.green),
                SizedBox(width: 12.w),
                _buildTypeButton('Expense', Colors.red),
              ],
            ),
            SizedBox(height: 16.h),
            _buildTextField(_amountController, 'Amount (PKR)', Icons.payments_outlined, keyboardType: TextInputType.number),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(prefixIcon: Icon(Icons.category_outlined, size: 18.w)),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(fontSize: 12.sp)))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            SizedBox(height: 16.h),
            _buildTextField(_descController, 'Description', Icons.description_outlined),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _isSubmitting ? null : _submit, child: const Text('SAVE TRANSACTION')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type, Color color) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(type, style: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.bold, fontSize: 12.sp)),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 12.sp),
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 18.w), contentPadding: EdgeInsets.symmetric(vertical: 12.h)),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}
