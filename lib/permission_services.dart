import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;

class PermissionsService {
  Future<bool> checkPermissionsAndLocationService() async {
    final statuses = await [Permission.location].request();

    if (statuses[Permission.location] != PermissionStatus.granted) {
      return false;
    }

    loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    return true;
  }
}
