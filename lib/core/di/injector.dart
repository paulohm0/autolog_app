import 'package:autolog_app/data/repository/auth_repository_impl.dart';
import 'package:autolog_app/data/repository/battery_change_repository_impl.dart';
import 'package:autolog_app/data/repository/maintenance_repository_impl.dart';
import 'package:autolog_app/data/repository/oil_change_repository_impl.dart';
import 'package:autolog_app/data/repository/vehicle_repository_impl.dart';
import 'package:autolog_app/domain/repository/i_auth_repository.dart';
import 'package:autolog_app/domain/repository/i_battery_change_repository.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:autolog_app/domain/repository/i_oil_change_repository.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/home/home_cubit.dart';
import 'package:autolog_app/ui/routes/login/login_cubit.dart';
import 'package:autolog_app/ui/routes/oil_battery/battery_change_cubit.dart';
import 'package:autolog_app/ui/routes/oil_battery/oil_change_cubit.dart';
import 'package:autolog_app/ui/routes/profile/profile_cubit.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_cubit.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );
  getIt.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(),
  );

  //
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );
  getIt.registerLazySingleton<IVehicleRepository>(
    () => VehicleRepositoryImpl(
      firestoreDB: getIt<FirebaseFirestore>(),
    ),
  );
  getIt.registerLazySingleton<IMaintenanceRepository>(
    () => MaintenanceRepositoryImpl(
      firestoreDB: getIt<FirebaseFirestore>(),
    ),
  );
  getIt.registerLazySingleton<IOilChangeRepository>(
    () => OilChangeRepositoryImpl(
      firestoreDB: getIt<FirebaseFirestore>(),
    ),
  );
  getIt.registerLazySingleton<IBatteryChangeRepository>(
    () => BatteryChangeRepositoryImpl(
      firestoreDB: getIt<FirebaseFirestore>(),
    ),
  );

  //
  getIt.registerFactory(
    () => LoginCubit(repository: getIt<IAuthRepository>()),
  );
  getIt.registerFactory(
    () => RegisterVehicleCubit(repository: getIt<IVehicleRepository>()),
  );
  getIt.registerFactory(
    () => HomeCubit(
      vehicleRepository: getIt<IVehicleRepository>(),
      maintenanceRepository: getIt<IMaintenanceRepository>(),
    ),
  );
  getIt.registerFactory(
    () => RegisterServiceCubit(
      maintenanceRepository: getIt<IMaintenanceRepository>(),
      vehicleRepository: getIt<IVehicleRepository>(),
    ),
  );
  getIt.registerFactory(
    () => OilChangeCubit(
      oilChangeRepository: getIt<IOilChangeRepository>(),
      vehicleRepository: getIt<IVehicleRepository>(),
    ),
  );
  getIt.registerFactory(
    () => BatteryChangeCubit(
      batteryChangeRepository: getIt<IBatteryChangeRepository>(),
      vehicleRepository: getIt<IVehicleRepository>(),
    ),
  );
  getIt.registerFactory(
    () => ProfileCubit(repository: getIt<IAuthRepository>()),
  );
}
