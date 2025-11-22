import '../../domain/entities/dashboard_models.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../mappers/dashboard_mapper.dart';
import '../services/kursach_api.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._api);

  final KursachApi _api;

  @override
  Future<DashboardData> fetchDashboard() async {
    final base = await _api.fetchDashboard();
    return base.toDomain();
  }
}
