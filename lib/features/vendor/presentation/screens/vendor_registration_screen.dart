import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';

class VendorRegistrationScreen extends ConsumerStatefulWidget {
  const VendorRegistrationScreen({super.key});
  @override
  ConsumerState<VendorRegistrationScreen> createState() => _VRSState();
}

class _VRSState extends ConsumerState<VendorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;
  final _storeNameCtrl    = TextEditingController();
  final _storeDescCtrl    = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _bankNameCtrl     = TextEditingController();
  final _accountNameCtrl  = TextEditingController();
  final _accountNumCtrl   = TextEditingController();
  String _businessType    = 'Individual';

  @override
  void dispose() {
    for (final c in [_storeNameCtrl,_storeDescCtrl,_phoneCtrl,_emailCtrl,
        _bankNameCtrl,_accountNameCtrl,_accountNumCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.vendorRegistration),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => _step == 0 ? context.pop() : setState(() => _step--)),
      ),
      body: Column(children: [
        LinearProgressIndicator(value: (_step + 1) / 3, backgroundColor: AppColors.grey200,
            color: AppColors.primary, minHeight: 3),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (i) => _StepDot(
                  label: ['Store Info','Business','Payout'][i],
                  isActive: i == _step, isDone: i < _step))),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(key: _formKey,
              child: _step == 0 ? _storeInfo() : _step == 1 ? _bizInfo() : _payoutInfo()),
        )),
        SafeArea(child: Padding(
          padding: const EdgeInsets.fromLTRB(16,8,16,16),
          child: SizedBox(width: double.infinity,
              child: ElevatedButton(onPressed: _next,
                  child: Text(_step == 2 ? 'Submit Application' : 'Continue'))),
        )),
      ]),
    );
  }

  Widget _storeInfo() => Column(children: [
    AuthTextField(controller: _storeNameCtrl, label: AppStrings.storeName,
        hint: 'e.g. TechHub ZM', prefixIcon: Icons.storefront_outlined,
        validator: (v) => Validators.validateMinLength(v, 3, 'Store name')),
    const SizedBox(height: 14),
    AuthTextField(controller: _storeDescCtrl, label: AppStrings.storeDescription,
        hint: 'Describe your store…', prefixIcon: Icons.description_outlined, maxLines: 4),
    const SizedBox(height: 14),
    AuthTextField(controller: _phoneCtrl, label: 'Business Phone',
        hint: '+260 97X XXX XXX', prefixIcon: Icons.phone_outlined,
        keyboardType: TextInputType.phone, validator: Validators.validatePhone),
    const SizedBox(height: 14),
    AuthTextField(controller: _emailCtrl, label: 'Business Email',
        hint: 'store@email.com', prefixIcon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress, validator: Validators.validateEmail),
  ]);

  Widget _bizInfo() => Column(children: [
    DropdownButtonFormField<String>(
      value: _businessType,
      decoration: const InputDecoration(labelText: 'Business Type',
          prefixIcon: Icon(Icons.business_outlined)),
      items: ['Individual','Sole Trader','Partnership','Limited Company']
          .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
      onChanged: (v) => setState(() => _businessType = v ?? 'Individual'),
    ),
    const SizedBox(height: 16),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.info.withOpacity(0.3))),
      child: const Row(children: [
        Icon(Icons.info_outline, color: AppColors.info, size: 18), SizedBox(width: 10),
        Expanded(child: Text('Upload your NRC/Business registration for faster verification.',
            style: TextStyle(color: AppColors.info, fontSize: 13))),
      ]),
    ),
    const SizedBox(height: 14),
    OutlinedButton.icon(onPressed: () {},
        icon: const Icon(Icons.upload_file_outlined), label: const Text('Upload ID / Business Docs'),
        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48))),
  ]);

  Widget _payoutInfo() => Column(children: [
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(0.3))),
      child: const Row(children: [
        Icon(Icons.shield_outlined, color: AppColors.success, size: 18), SizedBox(width: 10),
        Expanded(child: Text('Your bank details are encrypted and secure.',
            style: TextStyle(color: AppColors.success, fontSize: 13))),
      ]),
    ),
    const SizedBox(height: 16),
    AuthTextField(controller: _bankNameCtrl, label: 'Bank Name',
        hint: 'e.g. Zanaco, Stanbic, FNB', prefixIcon: Icons.account_balance_outlined,
        validator: (v) => Validators.validateRequired(v, 'Bank name')),
    const SizedBox(height: 14),
    AuthTextField(controller: _accountNameCtrl, label: 'Account Name',
        hint: 'Name on account', prefixIcon: Icons.person_outline_rounded,
        validator: (v) => Validators.validateRequired(v, 'Account name')),
    const SizedBox(height: 14),
    AuthTextField(controller: _accountNumCtrl, label: 'Account Number',
        hint: 'Enter account number', prefixIcon: Icons.pin_outlined,
        keyboardType: TextInputType.number,
        validator: (v) => Validators.validateRequired(v, 'Account number')),
    const SizedBox(height: 16),
    Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Commission Structure', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          SizedBox(height: 8),
          Text('Platform fee: 10% per sale\nPayouts processed every Friday',
              style: TextStyle(fontSize: 13, color: AppColors.grey700, height: 1.6)),
        ])),
  ]);

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    if (_step < 2) { setState(() => _step++); } else { _submit(); }
  }

  void _submit() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Application Submitted!'),
      content: const Text('We will review your application within 24-48 hours.'),
      actions: [ElevatedButton(
          onPressed: () { Navigator.pop(context); context.go(RouteNames.home); },
          child: const Text('Done'))],
    ));
  }
}

class _StepDot extends StatelessWidget {
  final String label; final bool isActive, isDone;
  const _StepDot({required this.label, required this.isActive, required this.isDone});
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(width: 24, height: 24,
        decoration: BoxDecoration(
          color: isDone ? AppColors.success : isActive ? AppColors.primary : AppColors.grey200,
          shape: BoxShape.circle),
        child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white)
            : isActive ? Container(width:10,height:10,decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)) : null),
    const SizedBox(height: 4),
    Text(label, style: TextStyle(fontSize: 10,
        color: isActive ? AppColors.primary : AppColors.grey400,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
  ]);
}
