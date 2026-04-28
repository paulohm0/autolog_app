import 'package:autolog_app/data/repository/vehicle_repository_impl.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  getIt.registerLazySingleton<IVehicleRepository>(
    () => VehicleRepositoryImpl(firestoreDB: FirebaseFirestore.instance),
  );
}
