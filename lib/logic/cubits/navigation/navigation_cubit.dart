// File: lib/logic/cubits/navigation/navigation_cubit.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'navigation_state.dart';

// Navigation cubit
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState(selectedIndex: 0));

  void changeTab(int index) {
    emit(NavigationState(selectedIndex: index));
  }

  void goToAllMemories() {
    emit(const NavigationState(selectedIndex: 0));
  }

  void goToSharedMemories() {
    emit(const NavigationState(selectedIndex: 1));
  }

  void goToProfile() {
    emit(const NavigationState(selectedIndex: 2));
  }
}