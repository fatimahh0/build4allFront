// lib/features/home/presentation/bloc/home_event.dart

import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// first load when we enter Home
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// pull-to-refresh or manual reload
class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}
