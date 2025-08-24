import 'package:get_it/get_it.dart';
import 'package:shareit/features/share/data/data_source/share_ds.dart';
import 'package:shareit/features/share/domain/repo/share_repo.dart';
import 'package:shareit/features/share/presentation/cubit/share_cubit.dart';

class Injections {
  static final GetIt _getIt = GetIt.instance;

  static Future<void> init() async {
    // Share Feature
    _getIt.registerLazySingleton<ShareDataSource>(() => ShareDataSource());
    _getIt.registerLazySingleton<ShareRepository>(
      () => ShareRepositoryImpl(_getIt<ShareDataSource>()),
    );
    _getIt.registerFactory<ShareCubit>(
      () => ShareCubit(_getIt<ShareRepository>()),
    );
  }

  static T get<T extends Object>() {
    return _getIt.get<T>();
  }
}
