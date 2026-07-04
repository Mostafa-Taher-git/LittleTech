import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:littletech/src/features/auth/data/services/auth_service.dart';
import 'package:littletech/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:littletech/src/features/auth/presentation/screens/login_screen.dart';
import 'package:littletech/src/features/home/presentation/bloc/counter_cubit.dart';
import 'package:littletech/src/features/home/presentation/screens/home_screen.dart';
import 'package:littletech/src/features/splash/presentation/screens/splash_screen.dart';
import 'package:littletech/src/features/game/data/repositories/game_repository.dart';
import 'package:littletech/src/features/game/domain/cubit/game_cubit.dart';
import 'package:littletech/src/features/game/domain/cubit/suptech_customization_cubit.dart';
import 'package:littletech/src/features/game/domain/cubit/theme_cubit.dart';

class LittleTechApp extends StatefulWidget {
  final Isar isar;

  const LittleTechApp({super.key, required this.isar});

  @override
  State<LittleTechApp> createState() => _LittleTechAppState();
}

class _LittleTechAppState extends State<LittleTechApp> {
  int? _userId;
  final _navKey = GlobalKey<NavigatorState>();
  int _authChangeSeq = 0;

  late final GameRepository _gameRepo;
  late final GameCubit _gameCubit;
  late final CounterCubit _counterCubit;
  late final SupTechCustomizationCubit _customizationCubit;
  late final ThemeCubit _themeCubit;
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _gameRepo = GameRepository(widget.isar);
    _gameCubit = GameCubit(_gameRepo, 0);
    _counterCubit = CounterCubit();
    _customizationCubit = SupTechCustomizationCubit();
    _themeCubit = ThemeCubit();
    _authCubit = AuthCubit();
    _loadUserId();
  }

  Future<int?> _resolveNewUserId() async {
    final userId = await AuthService.getFreshUserId();
    if (!mounted) return _userId;
    if (userId != null) {
      final user = await AuthService.getCurrentUser();
      if (user == null) {
        await AuthService.logout();
        return mounted ? null : _userId;
      }
    }
    return userId;
  }

  Future<void> _loadUserId() async {
    final userId = await _resolveNewUserId();
    if (!mounted) return;
    await _gameCubit.switchUser(userId);
    if (mounted) {
      setState(() => _userId = userId);
      final themeId = _gameCubit.state.progress.themeId;
      if (themeId != null) {
        _themeCubit.applyTheme(themeId);
      } else {
        _themeCubit.resetToDefault();
      }
    }
  }

  void _onAuthChanged({bool showAccountPicker = false}) {
    final seq = ++_authChangeSeq;
    _resolveNewUserId().then((newUserId) async {
      if (!mounted || seq != _authChangeSeq) return;

      await _gameCubit.switchUser(newUserId);
      await _counterCubit.reload();
      await _customizationCubit.reload();

      if (!mounted || seq != _authChangeSeq) return;
      setState(() => _userId = newUserId);

      final nav = _navKey.currentState;
      if (nav != null) {
        if (newUserId != null) {
          nav.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
        } else {
          nav.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => LoginScreen(showAccountPicker: showAccountPicker)),
            (_) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _counterCubit),
        BlocProvider.value(value: _themeCubit),
        BlocProvider.value(value: _customizationCubit),
        BlocProvider.value(value: _gameCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listener: (_, state) {
              if (state is LoginSuccess) {
                _onAuthChanged(showAccountPicker: false);
              } else if (state is LogoutSuccess) {
                _onAuthChanged(showAccountPicker: state.showAccountPicker);
              }
            },
          ),
          BlocListener<GameCubit, GameState>(
            listenWhen: (prev, curr) =>
                curr.progress.userId != 0 &&
                (prev.progress.themeId != curr.progress.themeId ||
                 prev.progress.userId != curr.progress.userId),
            listener: (context, state) {
              final themeId = state.progress.themeId;
              if (themeId != null) {
                context.read<ThemeCubit>().applyTheme(themeId);
              } else {
                context.read<ThemeCubit>().resetToDefault();
              }
            },
          ),
          BlocListener<GameCubit, GameState>(
            listenWhen: (prev, curr) =>
                curr.progress.userId != 0 &&
                !prev.persistError && curr.persistError,
            listener: (context, state) {
              final navCtx = _navKey.currentContext;
              if (navCtx == null) return;
              if (state.persistErrorCritical) {
                showDialog(
                  context: navCtx,
                  builder: (_) => AlertDialog(
                    title: const Text('Progress not saved'),
                    content: const Text(
                      'Your level completion could not be saved. '
                      'Please restart the app and check your storage.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(navCtx).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              } else {
                ScaffoldMessenger.of(navCtx).showSnackBar(
                  const SnackBar(content: Text('Failed to save progress')),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeData>(
          builder: (_, theme) => MaterialApp(
            navigatorKey: _navKey,
            title: 'LittleTech',
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const SplashScreen(),
          ),
        ),
      ),
    );
  }
}
