import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/session/session_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';

class MonkApp extends StatefulWidget {
  const MonkApp({super.key});

  @override
  State<MonkApp> createState() => _MonkAppState();
}

class _MonkAppState extends State<MonkApp> {
  late final SessionCubit _session;
  late final GoRouter _router;
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _session = getIt<SessionCubit>();
    _router = createAppRouter(_session);
    _authBloc = getIt<AuthBloc>()
      ..add(const AuthRestoreRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _session),
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: getIt<NotificationsCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Influencers Monk',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.brand(),
        routerConfig: _router,
      ),
    );
  }
}
