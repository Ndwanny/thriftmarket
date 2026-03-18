import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});
  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _compareCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in [_titleCtrl,_descCtrl,_priceCtrl,_compareCtrl,_stockCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addProduct),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Images
            Text('Product Images', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            SizedBox(height: 90,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                GestureDetector(onTap: () {},
                  child: Container(width: 90, margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey300, style: BorderStyle.solid)),
                      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate_outlined, color: AppColors.grey400, size: 28),
                        SizedBox(height: 4),
                        Text('Add Photo', style: TextStyle(fontSize: 10, color: AppColors.grey400)),
                      ]))),
              ]),
            ),
            const SizedBox(height: 20),
            Text('Product Details', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            AuthTextField(controller: _titleCtrl, label: 'Product Title',
                hint: 'e.g. Wireless Bluetooth Earbuds', prefixIcon: Icons.title,
                validator: (v) => Validators.validateMinLength(v, 5, 'Title')),
            const SizedBox(height: 12),
            AuthTextField(controller: _descCtrl, label: AppStrings.description,
                hint: 'Describe your product in detail…',
                prefixIcon: Icons.description_outlined, maxLines: 5),
            const SizedBox(height: 20),
            Text('Pricing', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: AuthTextField(controller: _priceCtrl, label: 'Price (K)',
                  hint: '0.00', prefixIcon: Icons.sell_outlined,
                  keyboardType: TextInputType.number, validator: Validators.validatePrice)),
              const SizedBox(width: 12),
              Expanded(child: AuthTextField(controller: _compareCtrl, label: 'Compare at (K)',
                  hint: '0.00', prefixIcon: Icons.discount_outlined,
                  keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 20),
            Text('Inventory', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            AuthTextField(controller: _stockCtrl, label: 'Stock Quantity',
                hint: '0', prefixIcon: Icons.inventory_outlined,
                keyboardType: TextInputType.number, validator: Validators.validateQuantity),
            const SizedBox(height: 28),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Publish Product'),
              ),
            ),
            const SizedBox(height: 60),
          ]),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product published successfully!')));
      context.pop();
    }
  }
}
