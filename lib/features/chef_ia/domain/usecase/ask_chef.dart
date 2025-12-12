import 'package:bienestar_integral_app/features/chef_ia/domain/repository/chef_repository.dart';

class AskChef {
  final ChefRepository repository;

  AskChef(this.repository);

  Future<String> call(int kitchenId, String question) async {
    return await repository.askChef(kitchenId, question);
  }
}