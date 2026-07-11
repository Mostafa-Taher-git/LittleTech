import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:littletech/src/core/constants/colors.dart';
import 'package:littletech/src/core/navigation/nav.dart';
import 'package:littletech/src/core/widgets/app_widgets.dart';
import 'package:littletech/src/features/auth/data/models/user_model.dart';
import 'package:littletech/src/features/auth/data/services/auth_service.dart';
import 'package:littletech/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'register_screen.dart';
import 'forget_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool showAccountPicker;

  const LoginScreen({super.key, this.showAccountPicker = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  List<UserModel> _users = [];
  bool _usersLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.showAccountPicker) _loadUsers();
  }

  Future<void> _loadUsers() async {
    _users = await AuthService.getAllUsers();
    if (mounted) setState(() => _usersLoaded = true);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                showErrorToast(context, state.message);
              }
            },
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Gap(Spacing.lg),
                      Center(
                        child: Image.asset(
                          'assets/icon/icon.png',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      )
                          .animate()
                          .scale(duration: 500.ms, curve: Curves.easeOutBack),
                      const Gap(Spacing.lg),
                      const Center(
                        child: Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Gap(Spacing.sm),
                      const Center(
                        child: Text(
                          'Sign in to continue troubleshooting',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                      const Gap(Spacing.xl2),
                      if (widget.showAccountPicker && _users.isNotEmpty) ...[
                        const Text('Quick Login',
                            style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                                letterSpacing: 1)),
                        const Gap(Spacing.ms),
                        SizedBox(
                          height: 80,
                          child: _usersLoaded
                              ? ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _users.length,
                                  separatorBuilder: (_, __) => const Gap(Spacing.ms),
                                  itemBuilder: (_, i) {
                                    final u = _users[i];
                                    final selected =
                                        _usernameCtrl.text == u.username;
                                    return GestureDetector(
                                      onTap: () => setState(() =>
                                          _usernameCtrl.text = u.username),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: 68,
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? scheme.secondary
                                                  .withValues(alpha: 0.15)
                                              : Colors.white
                                                  .withValues(alpha: 0.06),
                                          borderRadius:
                                              BorderRadius.circular(Radii.lg),
                                          border: Border.all(
                                              color: selected
                                                  ? scheme.secondary
                                                  : Colors.transparent),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(u.avatarIcon,
                                                style: const TextStyle(
                                                    fontSize: 26)),
                                            const Gap(Spacing.xs),
                                            Text(u.username,
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white54)),
                        ),
                        const Gap(Spacing.xl),
                      ],
                      TextFormField(
                        controller: _usernameCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'tech_expert',
                          labelStyle: const TextStyle(color: Colors.white54),
                          hintStyle: const TextStyle(color: Colors.white30),
                          prefixIcon: const Icon(Icons.person_outline,
                              color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.06),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Radii.md),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Radii.md),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Radii.md),
                            borderSide: BorderSide(
                                color: scheme.secondary, width: 1.5),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Enter username' : null,
                      ),
                      const Gap(Spacing.md),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: '••••••••',
                          labelStyle: const TextStyle(color: Colors.white54),
                          hintStyle: const TextStyle(color: Colors.white30),
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.white54),
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white54),
                            tooltip:
                                _obscure ? 'Show password' : 'Hide password',
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.06),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Radii.md),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Radii.md),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Radii.md),
                            borderSide: BorderSide(
                                color: scheme.secondary, width: 1.5),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Enter password' : null,
                      ),
                      const Gap(Spacing.sm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              Nav.push(context, const ForgetPasswordScreen()),
                          child: const Text('Forgot Password?',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 13)),
                        ),
                      ),
                      const Gap(Spacing.xl),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (_, state) {
                          return SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: scheme.secondary,
                                foregroundColor: scheme.onSecondary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Radii.lg)),
                              ),
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<AuthCubit>().login(
                                              username:
                                                  _usernameCtrl.text.trim(),
                                              password: _passwordCtrl.text,
                                            );
                                      }
                                    },
                              child: state is AuthLoading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: scheme.onSecondary))
                                  : const Text('Login',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                            ),
                          );
                        },
                      ),
                      const Gap(Spacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?",
                              style: TextStyle(color: Colors.white54)),
                          TextButton(
                            onPressed: () =>
                                Nav.push(context, const RegisterScreen()),
                            child: Text('Sign Up',
                                style: TextStyle(
                                    color: scheme.secondary,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const Gap(Spacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
