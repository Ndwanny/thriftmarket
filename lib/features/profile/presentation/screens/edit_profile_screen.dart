import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}
class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController();
  late final _phoneCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl.text = user?.fullName ?? '';
    _phoneCtrl.text = user?.phone ?? '';
  }
  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(key: _formKey, child: Column(children: [
          Stack(alignment: Alignment.bottomRight, children: [
            CircleAvatar(radius: 50, backgroundColor: AppColors.primaryContainer,
                backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                child: user?.avatarUrl == null
                    ? Text(user?.fullName.initials ?? '?',
                        style: const TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.w700)) : null),
            Container(width: 32, height: 32,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16)),
          ]),
          const SizedBox(height: 28),
          AuthTextField(controller: _nameCtrl, label: AppStrings.fullName,
              hint: 'Your full name', prefixIcon: Icons.person_outline_rounded,
              textCapitalization: TextCapitalization.words,
              validator: Validators.validateFullName),
          const SizedBox(height: 14),
          TextFormField(initialValue: user?.email,
              enabled: false,
              decoration: const InputDecoration(labelText: AppStrings.email,
                  prefixIcon: Icon(Icons.email_outlined))),
          const SizedBox(height: 14),
          AuthTextField(controller: _phoneCtrl, label: AppStrings.phoneNumber,
              hint: '+260 97X XXX XXX', prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white))
                  : const Text(AppStrings.save),
            ),
          ),
        ])),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!')));
      context.pop();
    }
  }
}
