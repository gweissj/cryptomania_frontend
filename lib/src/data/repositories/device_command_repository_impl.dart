import '../../domain/entities/sell.dart';
import '../../domain/repositories/device_command_repository.dart';
import '../mappers/sell_mapper.dart';
import '../services/kursach_api.dart';

class DeviceCommandRepositoryImpl implements DeviceCommandRepository {
  DeviceCommandRepositoryImpl(this._api);

  final KursachApi _api;

  @override
  Future<DeviceCommand> dispatch({
    required String action,
    Map<String, dynamic>? payload,
    String sourceDevice = 'mobile',
    String? sourceDeviceId,
    String targetDevice = 'desktop',
    String? targetDeviceId,
    int ttlSeconds = 60,
  }) async {
    final dto = await _api.dispatchDeviceCommand(
      action: action,
      payload: payload,
      sourceDevice: sourceDevice,
      sourceDeviceId: sourceDeviceId,
      targetDevice: targetDevice,
      targetDeviceId: targetDeviceId,
      ttlSeconds: ttlSeconds,
    );
    return dto.toDomain();
  }

  @override
  Future<DeviceCommandPoll> poll({
    required String targetDevice,
    String? targetDeviceId,
    int limit = 10,
  }) async {
    final dto = await _api.pollDeviceCommands(
      targetDevice: targetDevice,
      targetDeviceId: targetDeviceId,
      limit: limit,
    );
    return dto.toDomain();
  }

  @override
  Future<DeviceCommand> acknowledge({
    required int commandId,
    required String status,
  }) async {
    final dto = await _api.acknowledgeDeviceCommand(
      commandId: commandId,
      status: status,
    );
    return dto.toDomain();
  }
}
