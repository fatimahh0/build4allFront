import 'package:build4front/features/auth/data/repository/auth_repository_impl.dart';
import 'package:build4front/features/auth/data/services/admin_token_store.dart';
import 'package:build4front/features/auth/domain/usecases/send_verification_code.dart';
import 'package:build4front/features/auth/presentation/register/bloc/register_bloc.dart';
import 'package:build4front/features/auth/presentation/register/screens/user_register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../../common/widgets/primary_button.dart';
import '../../../../../common/widgets/app_text_field.dart';
import '../../../../../common/widgets/app_toast.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/theme/theme_cubit.dart';
import '../../../../../core/exceptions/exception_mapper.dart';
import '../../../../../core/config/env.dart';

import '../../../../shell/presentation/screens/main_shell.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

import 'package:build4front/features/auth/domain/facade/dual_login_orchestrator.dart';

enum LoginMethod { email, phone }

class UserLoginScreen extends StatefulWidget {
  final AppConfig appConfig;

  const UserLoginScreen({super.key, required this.appConfig});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  LoginMethod _method = LoginMethod.email;
  String? _fullPhone;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final identifier = _method == LoginMethod.email
        ? _emailCtrl.text.trim()
        : (_fullPhone ?? '').trim();

    if (identifier.isEmpty) {
      AppToast.show(context, l10n.loginMissingIdentifier, isError: true);
      return;
    }

    try {
      // loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // grab the underlying AuthApiService from DI (through repo)
      final repo = context.read<AuthRepositoryImpl>();
      final authApi = repo.api;

      final orchestrator = DualLoginOrchestrator(
        authApi: authApi,
        adminStore: AdminTokenStore(),
      );

      final result = await orchestrator.login(
        identifier: identifier,
        password: _passwordCtrl.text,
        usePhoneForUser: _method == LoginMethod.phone,
        ownerProjectLinkId: int.tryParse(Env.ownerProjectLinkId) ?? 0,
      );

      if (mounted) Navigator.of(context).pop(); // close loader

      if (result.none) {
        AppToast.show(
          context,
          result.error ?? l10n.authErrorGeneric,
          isError: true,
        );
        return;
      }

      if (result.both) {
        final choice = await showModalBottomSheet<String>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) {
            final t = Theme.of(ctx).textTheme;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose how to sign in',
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.verified_user_outlined),
                    title: const Text('Enter as Owner (Admin)'),
                    subtitle: Text('Role: ${result.adminRole}'),
                    onTap: () => Navigator.pop(ctx, 'admin'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Enter as User'),
                    subtitle: Text(
                      result.userEntity?.email ??
                          result.userEntity?.username ??
                          'User',
                    ),
                    onTap: () => Navigator.pop(ctx, 'user'),
                  ),
                ],
              ),
            );
          },
        );

        if (choice == 'admin') {
          _goToAdmin(
            context,
            role: result.adminRole!,
            admin: result.adminData!,
          );
        } else if (choice == 'user') {
          _goToUserHome(context);
        }
        return;
      }

      if (result.adminOk) {
        _goToAdmin(context, role: result.adminRole!, admin: result.adminData!);
        return;
      }

      if (result.userOk) {
        _goToUserHome(context);
        return;
      }

      AppToast.show(context, l10n.authErrorGeneric, isError: true);
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // close loader if still open
      }
      final msg = ExceptionMapper.toMessage(e);
      AppToast.show(context, msg, isError: true);
    }
  }

  void _goToUserHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainShell(appConfig: widget.appConfig)),
    );
  }

  void _goToAdmin(
    BuildContext context, {
    required String role,
    required Map<String, dynamic> admin,
  }) {
    // Regardless of role, go to unified admin dashboard
    Navigator.of(context).pushNamedAndRemoveUntil('/admin', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeState = context.watch<ThemeCubit>().state;
    final colors = themeState.tokens.colors;
    final card = themeState.tokens.card;

    final t = Theme.of(context).textTheme;
    final isPhone = _method == LoginMethod.phone;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                // (Keep Bloc listener for pure user-only pathway if you still dispatch)
                if (state.isLoggedIn && state.user != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MainShell(appConfig: widget.appConfig),
                    ),
                  );
                }

                if (state.error != null) {
                  final msg = ExceptionMapper.toMessage(state.error!);
                  AppToast.show(context, msg, isError: true);
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top avatar / logo
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colors.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person_outline,
                        color: colors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.appConfig.appName,
                      style: t.titleMedium?.copyWith(
                        color: colors.label,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.loginSubtitle,
                      style: t.bodyMedium?.copyWith(color: colors.body),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Card wrapper
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(card.padding),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(card.radius),
                        border: card.showBorder
                            ? Border.all(color: colors.border.withOpacity(0.15))
                            : null,
                        boxShadow: card.showShadow
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: card.elevation * 2,
                                  offset: Offset(0, card.elevation * 0.6),
                                ),
                              ]
                            : null,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.loginTitle,
                              style: t.headlineSmall?.copyWith(
                                color: colors.label,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _LoginMethodToggle(
                              method: _method,
                              onChanged: (m) {
                                if (_method == m) return;
                                setState(() {
                                  _method = m;
                                  _emailCtrl.clear();
                                  _fullPhone = null;
                                });
                              },
                              colors: colors,
                              textTheme: t,
                              l10n: l10n,
                            ),

                            const SizedBox(height: 20),

                            if (!isPhone)
                              AppTextField(
                                label: l10n.emailLabel,
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) return l10n.fieldRequired;
                                  if (!v.contains('@'))
                                    return l10n.invalidEmail;
                                  return null;
                                },
                              )
                            else
                              _PhoneFieldIntl(
                                colors: colors,
                                card: card,
                                textTheme: t,
                                l10n: l10n,
                                onChanged: (fullPhone) =>
                                    _fullPhone = fullPhone,
                              ),

                            const SizedBox(height: 16),

                            AppTextField(
                              label: l10n.passwordLabel,
                              controller: _passwordCtrl,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return l10n.fieldRequired;
                                if (value.length < 6)
                                  return l10n.passwordTooShort;
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: navigate to Forgot Password
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  l10n.forgotPassword,
                                  style: t.bodyMedium?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            PrimaryButton(
                              label: l10n.loginButton,
                              isLoading: state
                                  .isLoading, // still shows spinner if Bloc path used
                              onPressed: () => _onLoginPressed(context),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.noAccountText,
                          style: t.bodyMedium?.copyWith(color: colors.body),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) {
                                  final repo = ctx.read<AuthRepositoryImpl>();
                                  return BlocProvider(
                                    create: (_) => RegisterBloc(
                                      sendVerificationCode:
                                          SendVerificationCode(repo),
                                    ),
                                    child: UserRegisterScreen(
                                      appConfig: widget.appConfig,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          child: Text(
                            l10n.signUpText,
                            style: t.bodyMedium?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginMethodToggle extends StatelessWidget {
  final LoginMethod method;
  final ValueChanged<LoginMethod> onChanged;
  final dynamic colors;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  const _LoginMethodToggle({
    required this.method,
    required this.onChanged,
    required this.colors,
    required this.textTheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isEmail = method == LoginMethod.email;
    final isPhone = method == LoginMethod.phone;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.background.withOpacity(0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: l10n.loginWithEmail,
              selected: isEmail,
              onTap: () => onChanged(LoginMethod.email),
              colors: colors,
              textTheme: textTheme,
            ),
          ),
          Expanded(
            child: _Segment(
              label: l10n.loginWithPhone,
              selected: isPhone,
              onTap: () => onChanged(LoginMethod.phone),
              colors: colors,
              textTheme: textTheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final dynamic colors;
  final TextTheme textTheme;

  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: selected ? colors.onPrimary : colors.body,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneFieldIntl extends StatelessWidget {
  final dynamic colors;
  final dynamic card;
  final TextTheme textTheme;
  final AppLocalizations l10n;
  final ValueChanged<String> onChanged;

  const _PhoneFieldIntl({
    required this.colors,
    required this.card,
    required this.textTheme,
    required this.l10n,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      initialCountryCode: 'LB',
      decoration: InputDecoration(
        labelText: l10n.phoneLabel,
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(card.radius),
          borderSide: BorderSide(color: colors.border.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(card.radius),
          borderSide: BorderSide(color: colors.border.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(card.radius),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
      ),
      dropdownTextStyle: textTheme.bodyMedium?.copyWith(color: colors.label),
      style: textTheme.bodyMedium?.copyWith(color: colors.label),
      flagsButtonPadding: const EdgeInsets.only(left: 8),
      onChanged: (phone) => onChanged(phone.completeNumber),
      validator: (phone) {
        if (phone == null || phone.number.trim().isEmpty) {
          return l10n.fieldRequired;
        }
        if (phone.number.trim().length < 6) {
          return l10n.invalidPhone;
        }
        return null;
      },
    );
  }
}
