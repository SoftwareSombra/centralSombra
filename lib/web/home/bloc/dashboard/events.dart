abstract class DashboardEvent {}

class ChangeDashboard extends DashboardEvent {
  final int index;
  ChangeDashboard(this.index);
}
