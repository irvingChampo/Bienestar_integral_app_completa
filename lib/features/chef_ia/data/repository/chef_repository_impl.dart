import 'package:bienestar_integral_app/features/chef_ia/data/datasource/chef_datasource.dart';
import 'package:bienestar_integral_app/features/chef_ia/domain/repository/chef_repository.dart';

class ChefRepositoryImpl implements ChefRepository {
  final ChefDatasource datasource;

  ChefRepositoryImpl({required this.datasource});

  @override
  Future<String> askChef(int kitchenId, String question) async {
    return await datasource.askChef(kitchenId, question);
  }
}