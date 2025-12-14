class PredictionResult {
  final String ingrediente;
  final int cluster;
  final String etiqueta;
  final String sugerido;

  PredictionResult({
    required this.ingrediente,
    required this.cluster,
    required this.etiqueta,
    required this.sugerido,
  });
}