import 'package:bienestar_integral_app/core/application/app_state.dart';
import 'package:bienestar_integral_app/core/application/theme_provider.dart';
import 'package:bienestar_integral_app/core/di/service_locator.dart';
// Providers "Normales" (No migrados completamente a DI constructor puro, pero aceptan dependencias)
import 'package:bienestar_integral_app/features/account_status/presentation/providers/account_status_provider.dart';
import 'package:bienestar_integral_app/features/admin_home/presentation/providers/admin_events_provider.dart';
import 'package:bienestar_integral_app/features/admin_home/presentation/providers/admin_home_provider.dart';
import 'package:bienestar_integral_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bienestar_integral_app/features/events/presentation/providers/event_details_provider.dart';
import 'package:bienestar_integral_app/features/events/presentation/providers/events_provider.dart';
import 'package:bienestar_integral_app/features/home/presentation/providers/home_provider.dart';
import 'package:bienestar_integral_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:bienestar_integral_app/features/register/presentation/providers/register_provider.dart';
// --- FEATURES MIGRADAS CON GET_IT ---
// 1. Chef IA
import 'package:bienestar_integral_app/features/chef_ia/domain/usecase/ask_chef.dart';
import 'package:bienestar_integral_app/features/chef_ia/presentation/providers/chef_provider.dart';
// 2. Inventory y Add Product
import 'package:bienestar_integral_app/features/inventory/domain/usecase/create_category.dart';
import 'package:bienestar_integral_app/features/inventory/domain/usecase/get_categories.dart';
import 'package:bienestar_integral_app/features/inventory/domain/usecase/get_kitchen_inventory.dart';
import 'package:bienestar_integral_app/features/inventory/domain/usecase/get_units.dart';
import 'package:bienestar_integral_app/features/inventory/domain/usecase/manage_product_stock.dart';
import 'package:bienestar_integral_app/features/inventory/domain/usecase/product_management.dart';
import 'package:bienestar_integral_app/features/inventory/presentation/providers/inventory_provider.dart';
// 3. My Events
import 'package:bienestar_integral_app/features/events/domain/usecase/get_my_event_registrations.dart';
import 'package:bienestar_integral_app/features/events/domain/usecase/unregister_from_event.dart';
import 'package:bienestar_integral_app/features/home/domain/usecase/get_my_kitchen_subscriptions.dart';
import 'package:bienestar_integral_app/features/my_events/presentation/provider/my_events_provider.dart';
// 4. Payments
import 'package:bienestar_integral_app/features/payments/domain/usecase/create_donation.dart';
import 'package:bienestar_integral_app/features/payments/presentation/providers/payment_provider.dart';
import 'package:bienestar_integral_app/myapp.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// 5. Ingredient Analysis
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/get_analysis_dataset.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/get_ingredient_history.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/predict_ingredient_demand.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/recluster_model.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/train_clustering_model.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/presentation/providers/ingredient_analysis_provider.dart';

// 6. Toxicity (Validación de texto)
import 'package:bienestar_integral_app/features/toxicity/domain/usecase/validate_text.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 1. INICIALIZAMOS EL SERVICE LOCATOR (DI)
  await setupServiceLocator();

  final appState = AppState();

  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (context) => MultiProvider(
        providers: [
          // --- PROVIDERS GLOBALES ESTÁNDAR ---
          ChangeNotifierProvider(create: (_) => appState),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider(appState)),
          ChangeNotifierProvider(create: (_) => RegisterProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => EventDetailsProvider()),
          ChangeNotifierProvider(create: (_) => EventsProvider()),
          ChangeNotifierProvider(create: (_) => AdminHomeProvider()),
          ChangeNotifierProvider(create: (_) => AccountStatusProvider()),

          // --- ADMIN EVENTS PROVIDER CON INYECCIÓN DE TOXICIDAD ---
          ChangeNotifierProvider(
            create: (_) => AdminEventsProvider(
              validateText: getIt<ValidateText>(),
            ),
          ),

          // --- PROVIDERS MIGRADOS CON INYECCIÓN DE DEPENDENCIAS ---
          // Payments Feature
          ChangeNotifierProvider(
            create: (_) => PaymentProvider(getIt<CreateDonation>()),
          ),
          // My Events Feature
          ChangeNotifierProvider(
            create: (_) => MyEventsProvider(
              getMyKitchenSubscriptions: getIt<GetMyKitchenSubscriptions>(),
              getMyEventRegistrations: getIt<GetMyEventRegistrations>(),
              unregisterFromEvent: getIt<UnregisterFromEvent>(),
            ),
          ),
          // Inventory y tambien Add Product Feature
          ChangeNotifierProvider(
            create: (_) => InventoryProvider(
              getKitchenInventory: getIt<GetKitchenInventory>(),
              productManagement: getIt<ProductManagement>(),
              manageProductStock: getIt<ManageProductStock>(),
              getCategories: getIt<GetCategories>(),
              createCategory: getIt<CreateCategory>(),
              getUnits: getIt<GetUnits>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => IngredientAnalysisProvider(
              getDataset: getIt<GetAnalysisDataset>(),
              trainModel: getIt<TrainClusteringModel>(),
              reclusterModel: getIt<ReclusterModel>(),
              predictDemand: getIt<PredictIngredientDemand>(),
              getHistory: getIt<GetIngredientHistory>(),
            ),
          ),
          // Chef IA Feature
          ChangeNotifierProvider(
            create: (_) => ChefProvider(getIt<AskChef>()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}