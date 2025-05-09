part of 'navigation_bloc.dart';

@immutable
abstract class NavigationEvent {}

class TabChange extends NavigationEvent {
  final int tabIndex;

  TabChange({required this.tabIndex});

}