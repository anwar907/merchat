import 'package:equatable/equatable.dart';

enum ActionType { create, update }

class PendingAction extends Equatable {
  final int? localId;
  final String productId;
  final ActionType actionType;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  const PendingAction({
    this.localId,
    required this.productId,
    required this.actionType,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  PendingAction copyWith({
    int? localId,
    String? productId,
    ActionType? actionType,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return PendingAction(
      localId: localId ?? this.localId,
      productId: productId ?? this.productId,
      actionType: actionType ?? this.actionType,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  List<Object?> get props => [
    localId,
    productId,
    actionType,
    data,
    timestamp,
    retryCount,
  ];
}
