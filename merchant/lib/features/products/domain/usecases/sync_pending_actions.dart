import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/product_repository.dart';

class SyncPendingActions implements UseCase<void, NoParams> {
  final ProductRepository repository;

  SyncPendingActions(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.syncPendingActions();
  }
}
