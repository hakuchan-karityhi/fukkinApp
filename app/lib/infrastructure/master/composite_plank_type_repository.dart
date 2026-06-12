import "../../domain/models/custom_plank_type.dart";
import "../../domain/models/plank_type.dart";
import "../../domain/repositories/custom_plank_type_repository.dart";
import "../../domain/repositories/plank_type_repository.dart";
import "../../domain/services/custom_plank_type_mapper.dart";
import "plank_type_repository.dart";

class CompositePlankTypeRepository implements PlankTypeRepository {
  CompositePlankTypeRepository({
    required AssetPlankTypeRepository assetRepository,
    required CustomPlankTypeRepository customPlankTypeRepository,
  })  : _assetRepository = assetRepository,
        _customPlankTypeRepository = customPlankTypeRepository;

  final AssetPlankTypeRepository _assetRepository;
  final CustomPlankTypeRepository _customPlankTypeRepository;

  @override
  Future<List<PlankType>> getAll({required bool betaMode}) async {
    final official = await _assetRepository.getAll(betaMode: betaMode);
    final template = await _basicTemplate();
    final customTypes = await _customPlankTypeRepository.getAll();
    final customPlanks = customTypes
        .map(
          (custom) => CustomPlankTypeMapper.toPlankType(
            custom: custom,
            basicTemplate: template,
          ),
        )
        .toList();
    return [...official, ...customPlanks];
  }

  @override
  Future<PlankType?> getById(String id) async {
    if (CustomPlankTypeMapper.isCustomPlankTypeId(id)) {
      final custom = await _customPlankTypeRepository.getById(id);
      if (custom == null) return null;
      final template = await _basicTemplate();
      return CustomPlankTypeMapper.toPlankType(
        custom: custom,
        basicTemplate: template,
      );
    }
    return _assetRepository.getById(id);
  }

  Future<PlankType> _basicTemplate() async {
    final template =
        await _assetRepository.getById(CustomPlankTypeMapper.basicPlankTemplateId);
    if (template == null) {
      throw StateError("Missing plank template: ${CustomPlankTypeMapper.basicPlankTemplateId}");
    }
    return template;
  }
}

String generateCustomPlankTypeId() {
  final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  return "${CustomPlankType.idPrefix}$ts";
}
