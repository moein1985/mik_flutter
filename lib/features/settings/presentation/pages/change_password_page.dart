import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app_auth/presentation/bloc/app_auth_bloc.dart';
import '../../../app_auth/presentation/bloc/app_auth_state.dart';
import '../../../../injection_container.dart';
import '../../../app_auth/domain/usecases/change_password_usecase.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AppAuthBloc>().state;
    if (authState is! AppAuthAuthenticated) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mustBeLoggedIn)),
      );
      return;
    }

    final usecase = sl<ChangePasswordUseCase>();
    final result = await usecase.call(authState.user.id, _oldCtrl.text, _newCtrl.text);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordChanged))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.changePassword),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldCtrl,
                decoration: InputDecoration(labelText: l10n.password),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? l10n.invalidCredentials : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newCtrl,
                decoration: InputDecoration(labelText: l10n.changePassword),
                obscureText: true,
                validator: (v) => (v == null || v.length < 6) ? 'Password too short' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (v) => v != _newCtrl.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: Text(l10n.changePassword)),
            ],
          ),
        ),
      ),
    );
  }
}
