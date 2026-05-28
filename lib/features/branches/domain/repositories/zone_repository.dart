import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/features/branches/domain/repositories/zone_repository_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

class ZoneRepository implements ZoneRepositoryInterface {
  final ApiClient apiClient;
  ZoneRepository({required this.apiClient});

  @override
  Future<Response> check(double lat, double lng) => apiClient.getData(
        AppConstants.zonesCheckUri,
        query: {'lat': lat, 'lng': lng},
        handleError: false,
        timeoutSeconds: 6,
      );
}
