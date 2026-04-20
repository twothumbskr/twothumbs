import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../services/profile_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _busy = true; _error = null; });
    try {
      if (_isSignUp) {
        await AuthService.signUp(_emailCtrl.text.trim(), _pwCtrl.text);
      } else {
        await AuthService.signIn(_emailCtrl.text.trim(), _pwCtrl.text);
      }
      if (!mounted) return;
      final profile = await ProfileService.fetchCurrent();
      if (!mounted) return;
      context.go(profile == null ? '/onboarding' : '/');
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👍👍', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 8),
              Text('TwoThumbs',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              const Text('Korean Food Guide',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pwCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isSignUp ? 'Sign up' : 'Sign in'),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _isSignUp = !_isSignUp),
                child: Text(_isSignUp
                    ? 'Already have an account? Sign in'
                    : 'Create a new account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
