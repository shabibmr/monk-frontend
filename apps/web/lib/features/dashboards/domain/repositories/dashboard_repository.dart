import '../entities/dashboard.dart';

abstract class DashboardRepository {
  Future<BrandDashboard> brandDashboard(String brandId);
  Future<ProfileDashboard> profileDashboard(String profileId);
  Future<ManagerDashboard> managerDashboard();
  Future<ManualMetricEntry> enterMetrics({
    required String publishedPostId,
    required Map<String, dynamic> body,
  });
}
