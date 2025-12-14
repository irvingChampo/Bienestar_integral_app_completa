import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// Feature Imports
import 'package:bienestar_integral_app/features/chef_ia/data/datasource/chef_datasource.dart';
import 'package:bienestar_integral_app/features/chef_ia/data/repository/chef_repository_impl.dart';
import 'package:bienestar_integral_app/features/chef_ia/domain/repository/chef_repository.dart';
import 'package:bienestar_integral_app/features/chef_ia/domain/usecase/ask_chef.dart';
import 'package:bienestar_integral_app/features/payments/data/datasource/payment_datasource.dart';
import 'package:bienestar_integral_app/features/payments/data/repository/payment_repository_impl.dart';
import 'package:bienestar_integral_app/features/payments/domain/repository/payment_repository.dart';
import 'package:bienestar_integral_app/features/payments/domain/usecase/create_donation.dart';
import 'package:bienestar_integral_app/features/kitchen_schedule/data/datasource/kitchen_schedule_datasource.dart';
import 'package:bienestar_integral_app/features/kitchen_schedule/data/repository/kitchen_schedule_repository_impl.dart';
import 'package:bienestar_integral_app/features/kitchen_schedule/domain/repository/kitchen_schedule_repository.dart';
import 'package:bienestar_integral_app/features/kitchen_schedule/domain/usecase/create_kitchen_schedules.dart';
import 'package:bienestar_integral_app/features/inventory/data/datasource/inventory_datasource.dart';
import 'package:bienestar_integral_app/features/inventory/data/repository/inventory_repository_impl.dart';
import 'package:bienestar_integral_app/features/inventory/domain/repository/inventory_repository.dart';
import 'package:bienestar_integral_app/features/inventory/domain/usecase/create_category.dart';
import 'package:bienestar_integral_app/features/inventory/domain/usecase/get_categories.dart';
import 'package:bienestar_integral_app/features/inventory/domain/usecase/get_kitchen_inventory.dart';
import 'package:bienestar_integral_app/features/inventory/domain/usecase/get_units.dart';
import 'package:bienestar_integral_app/features/inventory/domain/usecase/manage_product_stock.dart';
import 'package:bienestar_integral_app/features/inventory/domain/usecase/product_management.dart';
import 'package:bienestar_integral_app/features/home/data/datasource/kitchen_datasource.dart';
import 'package:bienestar_integral_app/features/home/data/repository/kitchen_repository_impl.dart';
import 'package:bienestar_integral_app/features/home/domain/repository/kitchen_repository.dart';
import 'package:bienestar_integral_app/features/home/domain/usecase/get_my_kitchen_subscriptions.dart';
import 'package:bienestar_integral_app/features/events/data/datasource/event_datasource.dart';
import 'package:bienestar_integral_app/features/events/data/repository/event_repository_impl.dart';
import 'package:bienestar_integral_app/features/events/domain/repository/event_repository.dart';
import 'package:bienestar_integral_app/features/events/domain/usecase/get_my_event_registrations.dart';
import 'package:bienestar_integral_app/features/events/domain/usecase/unregister_from_event.dart';

// --- NUEVOS IMPORTS: INGREDIENT ANALYSIS ---
import 'package:bienestar_integral_app/features/ingredient_analysis/data/datasource/ingredient_analysis_datasource.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/data/repository/ingredient_analysis_repository_impl.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/repository/ingredient_analysis_repository.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/get_analysis_dataset.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/get_ingredient_history.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/predict_ingredient_demand.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/train_clustering_model.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/recluster_model.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton(() => http.Client());

  // CHEF IA
  getIt.registerLazySingleton<ChefDatasource>(
        () => ChefDatasourceImpl(client: getIt()),
  );
  getIt.registerLazySingleton<ChefRepository>(
        () => ChefRepositoryImpl(datasource: getIt()),
  );
  getIt.registerLazySingleton(() => AskChef(getIt()));

  // PAYMENTS
  getIt.registerLazySingleton<PaymentDatasource>(
        () => PaymentDatasourceImpl(client: getIt()),
  );
  getIt.registerLazySingleton<PaymentRepository>(
        () => PaymentRepositoryImpl(datasource: getIt()),
  );
  getIt.registerLazySingleton(() => CreateDonation(getIt()));

  // KITCHEN SCHEDULE
  getIt.registerLazySingleton<KitchenScheduleDatasource>(
        () => KitchenScheduleDatasourceImpl(client: getIt()),
  );
  getIt.registerLazySingleton<KitchenScheduleRepository>(
        () => KitchenScheduleRepositoryImpl(datasource: getIt()),
  );
  getIt.registerLazySingleton(() => CreateKitchenSchedules(getIt()));

  // INVENTORY y ADD PRODUCT
  getIt.registerLazySingleton<InventoryDatasource>(
        () => InventoryDatasourceImpl(client: getIt()),
  );
  getIt.registerLazySingleton<InventoryRepository>(
        () => InventoryRepositoryImpl(datasource: getIt()),
  );
  getIt.registerLazySingleton(() => GetKitchenInventory(getIt()));
  getIt.registerLazySingleton(() => ProductManagement(getIt()));
  getIt.registerLazySingleton(() => ManageProductStock(getIt()));
  getIt.registerLazySingleton(() => GetCategories(getIt()));
  getIt.registerLazySingleton(() => CreateCategory(getIt()));
  getIt.registerLazySingleton(() => GetUnits(getIt()));

  // HOME / KITCHEN
  getIt.registerLazySingleton<KitchenDatasource>(
        () => KitchenDatasourceImpl(client: getIt()),
  );
  getIt.registerLazySingleton<KitchenRepository>(
        () => KitchenRepositoryImpl(datasource: getIt()),
  );
  getIt.registerLazySingleton(() => GetMyKitchenSubscriptions(getIt()));

  // EVENTS
  getIt.registerLazySingleton<EventDatasource>(
        () => EventDatasourceImpl(client: getIt()),
  );
  getIt.registerLazySingleton<EventRepository>(
        () => EventRepositoryImpl(datasource: getIt()),
  );
  getIt.registerLazySingleton(() => GetMyEventRegistrations(getIt()));
  getIt.registerLazySingleton(() => UnregisterFromEvent(getIt()));

  // --- INGREDIENT ANALYSIS (NUEVO) ---
  getIt.registerLazySingleton<IngredientAnalysisDatasource>(
        () => IngredientAnalysisDatasourceImpl(client: getIt()),
  );
  getIt.registerLazySingleton<IngredientAnalysisRepository>(
        () => IngredientAnalysisRepositoryImpl(datasource: getIt()),
  );

  getIt.registerLazySingleton(() => GetAnalysisDataset(getIt()));
  getIt.registerLazySingleton(() => GetIngredientHistory(getIt()));
  getIt.registerLazySingleton(() => PredictIngredientDemand(getIt()));
  getIt.registerLazySingleton(() => TrainClusteringModel(getIt()));
  getIt.registerLazySingleton(() => ReclusterModel(getIt()));
}