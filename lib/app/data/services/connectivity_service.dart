import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isOffline = false.obs;

  Future<ConnectivityService> init() async {
    // Cek status awal
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    // Dengarkan perubahan status
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    return this;
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Pada versi terbaru connectivity_plus, mengembalikan List<ConnectivityResult>
    bool offline = true;
    for (var result in results) {
      if (result != ConnectivityResult.none) {
        offline = false;
        break;
      }
    }
    isOffline.value = offline;
    
    if (kDebugMode) {
      print('Connectivity status changed: isOffline = ${isOffline.value}');
    }
  }
}
