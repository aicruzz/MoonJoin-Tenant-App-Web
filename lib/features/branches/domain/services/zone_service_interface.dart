import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/branches/domain/models/zone_check_model.dart';

abstract class ZoneServiceInterface {
  Future<ResponseModel> check(double lat, double lng);
}

class ZoneCheckPayload {
  final ZoneCheckModel result;
  const ZoneCheckPayload(this.result);
}
