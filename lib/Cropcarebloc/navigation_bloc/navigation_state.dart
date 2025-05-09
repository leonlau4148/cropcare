part of 'navigation_bloc.dart';

@immutable
abstract class NavigationState {

  final int tabIndex;

  const NavigationState({required this.tabIndex});
}

class NavigationInitial extends NavigationState {
  const NavigationInitial({required super.tabIndex});

}
