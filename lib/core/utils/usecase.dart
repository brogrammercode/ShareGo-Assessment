import 'package:dartz/dartz.dart';
import 'package:shareit/core/utils/error.dart';

abstract interface class UseCase<SuccessType, Params> {
  Future<Either<CommonError, SuccessType>> call(Params params);
}

class NoParams {}
