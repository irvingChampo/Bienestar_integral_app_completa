class DatasetSummary {
  final int nItems;
  final List<DatasetItem> sample;

  DatasetSummary({required this.nItems, required this.sample});
}

class DatasetItem {
  final String ingrediente;
  final int categoriaId;
  final String unidadMedida;
  final double cantidadUnidad;
  final int cantidadCompras;
  final double tasaRecompra;
  final int diasPromedio;
  final int cluster;

  DatasetItem({
    required this.ingrediente,
    required this.categoriaId,
    required this.unidadMedida,
    required this.cantidadUnidad,
    required this.cantidadCompras,
    required this.tasaRecompra,
    required this.diasPromedio,
    required this.cluster,
  });
}