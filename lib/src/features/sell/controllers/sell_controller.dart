import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/network/dio_providers.dart';
import '../../../core/storage/auth_token_storage.dart';
import '../../../domain/entities/sell.dart';
import '../../../domain/repositories/device_command_repository.dart';
import '../../../domain/repositories/sell_repository.dart';
import '../../../utils/error_handler.dart';
import '../../home/controllers/home_controller.dart';
import '../../wallet/controllers/wallet_controller.dart';

final sellControllerProvider =
StateNotifierProvider.autoDispose<SellController, SellState>((ref) {
  final sellRepository = ref.watch(sellRepositoryProvider);
  final deviceRepository = ref.watch(deviceCommandRepositoryProvider);
  final tokenStorage = ref.watch(authTokenStorageProvider);
  return SellController(ref, sellRepository, deviceRepository, tokenStorage);
});

class SellController extends StateNotifier<SellState> {
  SellController(
      this._ref,
      this._sellRepository,
      this._deviceRepository,
      this._tokenStorage,
      ) : super(const SellState(isLoading: true)) {
    loadOverview();
  }

  final Ref _ref;
  final SellRepository _sellRepository;
  final DeviceCommandRepository _deviceRepository;
  final AuthTokenStorage _tokenStorage;

  Future<void> loadOverview() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final overview = await _sellRepository.fetchSellOverview();
      final selected = overview.holdings.isNotEmpty ? overview.holdings.first : null;
      state = state.copyWith(
        isLoading: false,
        overview: overview,
        holdings: overview.holdings,
        selectedAsset: selected,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: AppErrorHandler.readableMessage(error),
      );
    }
  }

  void selectAsset(SellableAsset asset) {
    state = state.copyWith(selectedAsset: asset, error: null, preview: null);
  }

  void setQuantityInput(String value) {
    state = state.copyWith(quantityInput: value, amountInput: '');
  }

  void setAmountInput(String value) {
    state = state.copyWith(amountInput: value, quantityInput: '');
  }

  void selectSource(String value) {
    state = state.copyWith(priceSource: value);
  }

  void clearSuccess() {
    if (state.lastSell != null) {
      state = state.copyWith(lastSell: null);
    }
  }

  Future<void> previewSell() async {
    final asset = state.selectedAsset;
    if (asset == null) {
      state = state.copyWith(error: 'Select an asset to sell');
      return;
    }

    final quantity = double.tryParse(state.quantityInput.replaceAll(',', '.'));
    final amount = double.tryParse(state.amountInput.replaceAll(',', '.'));

    if ((quantity == null || quantity <= 0) && (amount == null || amount <= 0)) {
      state = state.copyWith(error: 'Enter quantity or USD amount to sell');
      return;
    }

    state = state.copyWith(isPreviewLoading: true, error: null);
    try {
      final preview = await _sellRepository.previewSell(
        assetId: asset.id,
        quantity: quantity,
        amountUsd: amount,
        priceSource: state.priceSource,
      );
      state = state.copyWith(isPreviewLoading: false, preview: preview);
    } catch (error) {
      state = state.copyWith(
        isPreviewLoading: false,
        error: AppErrorHandler.readableMessage(error),
      );
    }
  }

  Future<void> executeSell() async {
    final asset = state.selectedAsset;
    if (asset == null) {
      state = state.copyWith(error: 'Select an asset to sell');
      return;
    }

    final quantity = double.tryParse(state.quantityInput.replaceAll(',', '.'));
    final amount = double.tryParse(state.amountInput.replaceAll(',', '.'));
    if ((quantity == null || quantity <= 0) && (amount == null || amount <= 0)) {
      state = state.copyWith(error: 'Enter quantity or USD amount to sell');
      return;
    }

    state = state.copyWith(isProcessing: true, error: null);
    try {
      final result = await _sellRepository.executeSell(
        assetId: asset.id,
        quantity: quantity,
        amountUsd: amount,
        priceSource: state.priceSource,
      );
      await loadOverview();
      _ref.read(walletControllerProvider.notifier).refresh();
      _ref.read(homeControllerProvider.notifier).refresh();
      state = state.copyWith(
        isProcessing: false,
        lastSell: result,
        preview: null,
        quantityInput: '',
        amountInput: '',
      );
    } catch (error) {
      state = state.copyWith(
        isProcessing: false,
        error: AppErrorHandler.readableMessage(error),
      );
    }
  }

  Future<void> dispatchLoginCommand({String? targetDeviceId}) async {
    state = state.copyWith(commandMessage: null, commandError: null);
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(commandError: 'Token not found. Please log in first.');
      return;
    }

    await _dispatchCommand(
      action: 'LOGIN_ON_DESKTOP',
      payload: {'access_token': token},
      targetDeviceId: targetDeviceId,
      ttlSeconds: 90,
    );
  }

  Future<void> requestDesktopSellSession({String? targetDeviceId}) async {
    final payload = <String, dynamic>{
      'requested_at': DateTime.now().toIso8601String(),
      'source': state.priceSource,
    };

    final asset = state.selectedAsset;
    if (asset != null) {
      payload['preferred_asset_id'] = asset.id;
      payload['preferred_symbol'] = asset.symbol;
    }

    final quantity = double.tryParse(state.quantityInput.replaceAll(',', '.'));
    final amount = double.tryParse(state.amountInput.replaceAll(',', '.'));

    if (quantity != null && quantity > 0) {
      payload['suggested_quantity'] = quantity;
    }
    if (amount != null && amount > 0) {
      payload['suggested_amount_usd'] = amount;
    }

    await _dispatchCommand(
      action: 'REQUEST_DESKTOP_SELL',
      payload: payload,
      targetDeviceId: targetDeviceId,
      ttlSeconds: 300,
    );
  }

  Future<void> pollCommands({required String targetDevice, String? targetDeviceId}) async {
    state = state.copyWith(commandError: null);
    try {
      final poll = await _deviceRepository.poll(
        targetDevice: targetDevice,
        targetDeviceId: targetDeviceId,
        limit: 10,
      );
      state = state.copyWith(pendingCommands: poll.commands);
    } catch (error) {
      state = state.copyWith(commandError: AppErrorHandler.readableMessage(error));
    }
  }

  Future<void> acknowledgeCommand(int id, String status) async {
    try {
      await _deviceRepository.acknowledge(commandId: id, status: status);
      final remaining = state.pendingCommands.where((e) => e.id != id).toList();
      state = state.copyWith(pendingCommands: remaining);
    } catch (error) {
      state = state.copyWith(commandError: AppErrorHandler.readableMessage(error));
    }
  }

  Future<void> _dispatchCommand({
    required String action,
    Map<String, dynamic>? payload,
    String? targetDeviceId,
    int ttlSeconds = 60,
  }) async {
    state = state.copyWith(commandMessage: null, commandError: null, isSendingCommand: true);
    try {
      await _deviceRepository.dispatch(
        action: action,
        payload: payload,
        targetDeviceId: targetDeviceId,
        ttlSeconds: ttlSeconds,
      );
      state = state.copyWith(
        isSendingCommand: false,
        commandMessage: 'Command sent to server',
      );
    } catch (error) {
      state = state.copyWith(
        isSendingCommand: false,
        commandError: AppErrorHandler.readableMessage(error),
      );
    }
  }
}

class SellState {
  const SellState({
    this.isLoading = false,
    this.isPreviewLoading = false,
    this.isProcessing = false,
    this.isSendingCommand = false,
    this.overview,
    this.holdings = const [],
    this.selectedAsset,
    this.preview,
    this.lastSell,
    this.priceSource = 'coincap',
    this.quantityInput = '',
    this.amountInput = '',
    this.error,
    this.pendingCommands = const [],
    this.commandMessage,
    this.commandError,
  });

  final bool isLoading;
  final bool isPreviewLoading;
  final bool isProcessing;
  final bool isSendingCommand;
  final SellDashboard? overview;
  final List<SellableAsset> holdings;
  final SellableAsset? selectedAsset;
  final SellPreview? preview;
  final SellExecution? lastSell;
  final String priceSource;
  final String quantityInput;
  final String amountInput;
  final String? error;
  final List<DeviceCommand> pendingCommands;
  final String? commandMessage;
  final String? commandError;

  SellState copyWith({
    bool? isLoading,
    bool? isPreviewLoading,
    bool? isProcessing,
    bool? isSendingCommand,
    SellDashboard? overview,
    List<SellableAsset>? holdings,
    SellableAsset? selectedAsset,
    SellPreview? preview,
    SellExecution? lastSell,
    String? priceSource,
    String? quantityInput,
    String? amountInput,
    Object? error = _sentinel,
    List<DeviceCommand>? pendingCommands,
    Object? commandMessage = _sentinel,
    Object? commandError = _sentinel,
  }) {
    return SellState(
      isLoading: isLoading ?? this.isLoading,
      isPreviewLoading: isPreviewLoading ?? this.isPreviewLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      isSendingCommand: isSendingCommand ?? this.isSendingCommand,
      overview: overview ?? this.overview,
      holdings: holdings ?? this.holdings,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      preview: preview ?? this.preview,
      lastSell: lastSell ?? this.lastSell,
      priceSource: priceSource ?? this.priceSource,
      quantityInput: quantityInput ?? this.quantityInput,
      amountInput: amountInput ?? this.amountInput,
      error: error == _sentinel ? this.error : error as String?,
      pendingCommands: pendingCommands ?? this.pendingCommands,
      commandMessage:
      commandMessage == _sentinel ? this.commandMessage : commandMessage as String?,
      commandError: commandError == _sentinel ? this.commandError : commandError as String?,
    );
  }
}

const _sentinel = Object();
