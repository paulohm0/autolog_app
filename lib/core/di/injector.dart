import 'package:autolog_app/data/repository/vehicle_repository_impl.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<IVehicleRepository>(
    () => VehicleRepositoryImpl(firestoreDB: getIt<FirebaseFirestore>()),
  );
  getIt.registerFactory(
    () => RegisterVehicleCubit(repository: getIt<IVehicleRepository>()),
  );
}
