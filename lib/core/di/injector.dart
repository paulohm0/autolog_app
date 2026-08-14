import 'package:autolog_app/data/repository/auth_repository_impl.dart';
import 'package:autolog_app/data/repository/maintenance_repository_impl.dart';
import 'package:autolog_app/data/repository/vehicle_repository_impl.dart';
import 'package:autolog_app/domain/repository/i_auth_repository.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/cubit/theme/theme_cubit.dart';
import 'package:autolog_app/ui/cubit/vehicle/vehicle_list_cubit.dart';
import 'package:autolog_app/ui/routes/home/home_cubit.dart';
import 'package:autolog_app/ui/routes/login/login_cubit.dart';
import 'package:autolog_app/ui/routes/main_navigation/vehicle_check_cubit.dart';
import 'package:autolog_app/ui/routes/profile/profile_cubit.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_cubit.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

void setupDependencyInjection(SharedPreferences prefs) {
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(prefs: getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );
  getIt.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(),
  );

  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );
  getIt.registerLazySingleton<IVehicleRepository>(
    () => VehicleRepositoryImpl(
      firestoreDB: getIt<FirebaseFirestore>(),
      firebaseAuth: getIt<FirebaseAuth>(),
    ),
  );
  getIt.registerLazySingleton<IMaintenanceRepository>(
    () => MaintenanceRepositoryImpl(
      firestoreDB: getIt<FirebaseFirestore>(),
      firebaseAuth: getIt<FirebaseAuth>(),
    ),
  );

  // Fonte única da lista de veículos, compartilhada por todas as telas.
  getIt.registerLazySingleton<VehicleListCubit>(
    () => VehicleListCubit(
      repository: getIt<IVehicleRepository>(),
      maintenanceRepository: getIt<IMaintenanceRepository>(),
    ),
  );

  getIt.registerFactory(
    () => LoginCubit(repository: getIt<IAuthRepository>()),
  );
  getIt.registerFactory(
    () => RegisterVehicleService(repository: getIt<IVehicleRepository>()),
  );
  // Fonte única do histórico de manutenção (inclui óleo/bateria),
  // compartilhada entre Home e a aba Óleo/Bateria.
  getIt.registerLazySingleton<HomeCubit>(
    () => HomeCubit(maintenanceRepository: getIt<IMaintenanceRepository>()),
  );
  getIt.registerFactory(
    () => RegisterServiceCubit(
      maintenanceRepository: getIt<IMaintenanceRepository>(),
      vehicleRepository: getIt<IVehicleRepository>(),
    ),
  );
  getIt.registerFactory(
    () => ProfileCubit(
      repository: getIt<IAuthRepository>(),
      vehicleRepository: getIt<IVehicleRepository>(),
      maintenanceRepository: getIt<IMaintenanceRepository>(),
    ),
  );
  getIt.registerFactory(
    () => VehicleCheckCubit(vehicleRepository: getIt<IVehicleRepository>()),
  );
}
