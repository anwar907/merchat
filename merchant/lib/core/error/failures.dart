import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ConflictFailure extends Failure {
  final Map<String, dynamic>? serverData;

  const ConflictFailure(super.message, {this.serverData});

  @override
  List<Object> get props => [message, serverData ?? {}];
}
