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
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargamos dataset inicial
      final kitchenId = context.read<AdminHomeProvider>().kitchen?.id;
      if (kitchenId != null) {
        context.read<IngredientAnalysisProvider>().loadDataset(kitchenId);
      }
    });
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
    if (provider.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.successMessage!), backgroundColor: Colors.green),
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
            Tab(text: 'General'),
            Tab(text: 'Predicción'),
            Tab(text: 'Evolución'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GeneralView(provider: provider),
          _PredictionView(provider: provider),
          _HistoryView(provider: provider),
        ],
      ),
    );
  }
}

// VISTA 1: GENERAL
class _GeneralView extends StatelessWidget {
  final IngredientAnalysisProvider provider;
  const _GeneralView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final summary = provider.datasetSummary;
    final isLoading = provider.status == AnalysisStatus.loading;
    final kitchenId = context.read<AdminHomeProvider>().kitchen?.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Panel de Control del Modelo", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            "Administra el modelo de clustering para la predicción de demanda de ingredientes.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Dataset Actual", style: TextStyle(fontWeight: FontWeight.bold)),
                      if (isLoading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    ],
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.data_usage),
                    title: const Text("Elementos procesados"),
                    trailing: Text(
                      summary?.nItems.toString() ?? "0",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text("Acciones", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (isLoading || kitchenId == null) ? null : () => provider.train(kitchenId),
                  icon: const Icon(Icons.model_training),
                  label: const Text("Entrenar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (isLoading || kitchenId == null) ? null : () => provider.recluster(kitchenId),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Re-Clusterizar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (summary != null && summary.sample.isNotEmpty) ...[
            Text("Muestra del Dataset", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: summary.sample.length > 5 ? 5 : summary.sample.length,
              itemBuilder: (context, index) {
                final item = summary.sample[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item.ingrediente),
                    subtitle: Text("Compras: ${item.cantidadCompras} | Recompra: ${item.tasaRecompra}"),
                    trailing: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text("${item.cluster}"),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

// VISTA 2: PREDICCIÓN
class _PredictionView extends StatefulWidget {
  final IngredientAnalysisProvider provider;
  const _PredictionView({required this.provider});

  @override
  State<_PredictionView> createState() => _PredictionViewState();
}

class _PredictionViewState extends State<_PredictionView> {
  final _formKey = GlobalKey<FormState>();
  final _ingredienteCtrl = TextEditingController();
  final _categoriaIdCtrl = TextEditingController();
  final _unidadCtrl = TextEditingController();
  final _cantidadUnidadCtrl = TextEditingController();
  final _comprasCtrl = TextEditingController();
  final _tasaCtrl = TextEditingController();
  final _diasCtrl = TextEditingController();

  void _submit() {
    final kitchenId = context.read<AdminHomeProvider>().kitchen?.id;
    if (kitchenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: No se encontró ID de cocina")));
      return;
    }

    if (_formKey.currentState!.validate()) {
      widget.provider.predict(
        kitchenId: kitchenId,
        ingrediente: _ingredienteCtrl.text,
        categoriaId: int.parse(_categoriaIdCtrl.text),
        unidadMedida: _unidadCtrl.text,
        cantidadUnidad: double.parse(_cantidadUnidadCtrl.text),
        cantidadCompras: int.parse(_comprasCtrl.text),
        tasaRecompra: double.parse(_tasaCtrl.text),
        diasPromedio: int.parse(_diasCtrl.text),
      );
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

            AdminTextField(label: "Ingrediente", controller: _ingredienteCtrl, hint: "Ej. Tomate"),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AdminTextField(label: "Cat ID", controller: _categoriaIdCtrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: AdminTextField(label: "Unidad", controller: _unidadCtrl, hint: "kg, lt")),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AdminTextField(label: "Cant. x Unidad", controller: _cantidadUnidadCtrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: AdminTextField(label: "Compras Totales", controller: _comprasCtrl, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AdminTextField(label: "Tasa Recompra (0-1)", controller: _tasaCtrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: AdminTextField(label: "Días Promedio", controller: _diasCtrl, keyboardType: TextInputType.number)),
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

// VISTA 3: EVOLUCIÓN HISTÓRICA
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