class IngredientItem {
  final int id;
  final String ingrediente;
  final int categoriaId;
  final String unidadMedida;
  final String fechaCreacion;
  // NUEVO CAMPO
  final String etiqueta;

  IngredientItem({
    required this.id,
    required this.ingrediente,
    required this.categoriaId,
    required this.unidadMedida,
    required this.fechaCreacion,
    required this.etiqueta,
  });
}