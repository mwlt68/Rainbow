import 'package:rainbow/core/core_models/core_base_model.dart';

class SelectionModel<TModel extends CoreBaseModel> {
  TModel model;
  bool select;
  SelectionModel(this.model, {this.select = false});
}

extension MyExtension<T extends CoreBaseModel> on List<SelectionModel<T>> {
  
  List<SelectionModel<T>> updateCachedModels(List<T> newModels) {
    if (newModels == null) {
      return [];
    }
    if (this == null) {
      return newModels.map((e) => SelectionModel(e)).toList();
    } else {
      List<SelectionModel<T>> newCachedModelsSellection = [];
      for (var newModel in newModels) {
        var cached = this.firstWhere(
            (element) => element.model.id == newModel.id,
            orElse: () => null);
        var modelSellect = SelectionModel(newModel);
        if (cached != null) {
          modelSellect.select = cached.select;
        }
        newCachedModelsSellection.add(modelSellect);
      }
      return newCachedModelsSellection;
    }
  }

  List<String> get selectedModelsId => this
      .where((element) => element.select)
      .map<String>((e) => e.model.id)
      .toList();

  int get selectedModelCount => this.where((element) => element.select).length;

  List<T> get selectedModels =>
      this.where((element) => element.select)
      .map((e) => e.model)
      .toList();

  void setAllSelection(bool val){
    this.forEach((element) {
      element.select= val;
    });
  }
}
