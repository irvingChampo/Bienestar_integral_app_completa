import 'package:bienestar_integral_app/features/admin_home/presentation/providers/admin_home_provider.dart';
import 'package:bienestar_integral_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/presentation/providers/ingredient_analysis_provider.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/presentation/widgets/history_line_chart.dart';
import 'package:bienestar_integral_app/features/settings/presentation/widgets/home_app_bar.dart';
import 'package:bienestar_integral_app/shared/widgets/admin_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnalysisDashboardScreen extends StatefulWidget {
  const AnalysisDashboardScreen({super.key});

  @override
  State<AnalysisDashboardScreen> createState() => _AnalysisDashboardScreenState();
}

class _AnalysisDashboardScreenState extends State<AnalysisDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<IngredientAnalysisProvider>();

    if (provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!), backgroundColor: colors.error),
        );
        provider.clearMessages();
      });
    }

    return Scaffold(
      appBar: HomeAppBar(
        title: 'Análisis IA',
        showBackButton: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.onPrimary,
          unselectedLabelColor: colors.onPrimary.withOpacity(0.6),
          indicatorColor: colors.onPrimary,
          tabs: const [
            Tab(text: 'Predicción'),
            Tab(text: 'Evolución'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PredictionView(provider: provider),
          _HistoryView(provider: provider),
        ],
      ),
    );
  }
}

// --- VISTA 1: PREDICCIÓN ---
class _PredictionView extends StatefulWidget {
  final IngredientAnalysisProvider provider;
  const _PredictionView({required this.provider});

  @override
  State<_PredictionView> createState() => _PredictionViewState();
}

class _PredictionViewState extends State<_PredictionView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _ingredienteCtrl = TextEditingController(text: "Tomate");
  final _categoriaIdCtrl = TextEditingController(text: "4");
  final _unidadCtrl = TextEditingController(text: "kilogramos");
  final _cantidadUnidadCtrl = TextEditingController(text: "1.0");
  final _comprasCtrl = TextEditingController(text: "10");
  final _tasaCtrl = TextEditingController(text: "0.5");
  final _diasCtrl = TextEditingController(text: "7");

  void _submit() {
    // 1. Obtener ID de Cocina
    final kitchenId = context.read<AdminHomeProvider>().kitchen?.id;

    if (kitchenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: No se encontró ID de cocina. Recarga la app.")));
      return;
    }

    if (_formKey.currentState!.validate()) {
      // 2. Conversión Segura de Datos
      try {
        final catId = int.parse(_categoriaIdCtrl.text.trim());
        final cantUni = double.parse(_cantidadUnidadCtrl.text.trim());
        final cantCompras = int.parse(_comprasCtrl.text.trim());
        final tasa = double.parse(_tasaCtrl.text.trim());
        final dias = int.parse(_diasCtrl.text.trim());

        // 3. Llamada al Provider
        widget.provider.predict(
          kitchenId: kitchenId,
          ingrediente: _ingredienteCtrl.text.trim(),
          categoriaId: catId,
          unidadMedida: _unidadCtrl.text.trim(),
          cantidadUnidad: cantUni,
          cantidadCompras: cantCompras,
          tasaRecompra: tasa,
          diasPromedio: dias,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error en el formato de los números: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.provider.predictionResult;
    final isLoading = widget.provider.status == AnalysisStatus.loading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (result != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.green, size: 30),
                    const SizedBox(height: 8),
                    Text(result.etiqueta, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                    Text("Cluster: ${result.cluster}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text("Sugerencia: ${result.sugerido}", style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Text("Calcular Prioridad", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            AdminTextField(label: "Ingrediente", controller: _ingredienteCtrl, hint: "Ej. Tomate"),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AdminTextField(label: "Cat ID (Entero)", controller: _categoriaIdCtrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: AdminTextField(label: "Unidad", controller: _unidadCtrl, hint: "kg, lt")),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AdminTextField(label: "Cant. x Unidad", controller: _cantidadUnidadCtrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: AdminTextField(label: "Compras (Entero)", controller: _comprasCtrl, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AdminTextField(label: "Tasa Recompra (0.0-1.0)", controller: _tasaCtrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: AdminTextField(label: "Días Promedio (Entero)", controller: _diasCtrl, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 30),

            CustomButton(
              text: "Predecir Demanda",
              isLoading: isLoading,
              onPressed: _submit,
            )
          ],
        ),
      ),
    );
  }
}

// --- VISTA 2: EVOLUCIÓN HISTÓRICA ---
class _HistoryView extends StatefulWidget {
  final IngredientAnalysisProvider provider;
  const _HistoryView({required this.provider});

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  final _searchCtrl = TextEditingController();

  void _search() {
    final val = _searchCtrl.text.trim();
    final kitchenId = context.read<AdminHomeProvider>().kitchen?.id;

    if (kitchenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: No se encontró ID de cocina")));
      return;
    }

    FocusScope.of(context).unfocus();
    widget.provider.fetchHistory(kitchenId, val);
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.provider.history;
    final isLoading = widget.provider.status == AnalysisStatus.loading;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: "Buscar ingrediente (Ej. Arroz)",
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _search,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 24),

          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (history != null) ...[
            Text("Ingrediente: ${history.ingrediente}", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Expanded(child: HistoryLineChart(points: history.historial)),
          ] else
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Busca un ingrediente para ver su evolución", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}