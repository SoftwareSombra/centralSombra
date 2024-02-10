abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardChanged extends DashboardState {
  final int selectedIndex;
  DashboardChanged(this.selectedIndex);
}
