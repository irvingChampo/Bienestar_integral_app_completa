class ToxicityResponse {
  final bool permitido;
  final double probOfensivo;
  final String mensaje;

  ToxicityResponse({
    required this.permitido,
    required this.probOfensivo,
    required this.mensaje,
  });
}