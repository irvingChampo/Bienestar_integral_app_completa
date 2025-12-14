class IngredientHistory {
  final String ingrediente;
  final List<HistoryPoint> historial;

  IngredientHistory({required this.ingrediente, required this.historial});
}

class HistoryPoint {
  final String fecha;
  final int cluster;
  final int cantidadCompras;
  final double cantidadNormalizada;

  HistoryPoint({
    required this.fecha,
    required this.cluster,
    required this.cantidadCompras,
    required this.cantidadNormalizada,
  });
}