import '../entities/sell.dart';

abstract class DeviceCommandRepository {
  Future<DeviceCommand> dispatch({
    required String action,
    Map<String, dynamic>? payload,
    String sourceDevice,
    String? sourceDeviceId,
    String targetDevice,
    String? targetDeviceId,
    int ttlSeconds,
  });

  Future<DeviceCommandPoll> poll({
    required String targetDevice,
    String? targetDeviceId,
    int limit,
  });

  Future<DeviceCommand> acknowledge({
    required int commandId,
    required String status,
  });
}
