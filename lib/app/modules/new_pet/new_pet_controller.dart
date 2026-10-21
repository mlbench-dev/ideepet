import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/modules/new_pet/repository/dtos/request/breed_request.dart';
import 'package:idee_pet/app/modules/new_pet/repository/dtos/request/create_pet_request.dart';
import 'package:idee_pet/app/routes/biometric_routes.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/core_old/handler/handler.dart';
import 'repository/new_pet_repository.dart';

class NewPetController extends GetxController {
  final NewPetRepository _newPetRepository;
  final NavigationService _navigationService;
  final AppStateService appStateService;
  NewPetController(
    this._newPetRepository,
    this._navigationService,
    this.appStateService,
  );

  final PageController pageController = PageController();
  final currentPage = 0.obs;

  final healthPlans = <HealthPlanResponse>[].obs;
  final selectedHealthPlan = Rxn<HealthPlanResponse>();

  final severityList = <String>[].obs;
  final selectedSeverity = 'Não grave'.obs;
  final selectedDate = DateTime.now().obs;
  final healthConditionName = ''.obs;

  final healthComplete = false.obs;

  final isLoading = false.obs;

  @override
  Future<void> onReady() async {
    super.onReady();
    await _requestCamera();
    _getHealthPlans();
    _getSeverityList();
  }

  Future<void> _requestCamera() async {
    final cameraPermission = await requestPermission(Permission.camera);
    //final locationPermission = await requestPermission(Permission.location);
    if (!cameraPermission
        // && locationPermission
        ) {
      Get.offAllNamed(HomeRoutes.home, arguments: true);
      showError(message: 'A permissão de câmera é obrigatória para continuar');
    }
  }

  Future<void> _getHealthPlans() async {
    final result = await _newPetRepository.getHealthPlans();
    if (result.success) {
      healthPlans(result.result!);
      return;
    }
    showError(message: 'Erro ao buscar planos de saúde');
  }

  void setSelectedHealthPlan(HealthPlanResponse? value) {
    selectedHealthPlan(value);
    healthComplete(checkHealthComplete());
  }

  void _getSeverityList() {
    severityList(SeverityHealthEnum.values
        .map((severity) => severityHealthToString(severity))
        .toList());
  }

  void setSeverity(String severity) {
    selectedSeverity(severity);
    healthComplete(checkHealthComplete());
  }

  void setDate(DateTime date) {
    selectedDate(date);
    healthComplete(checkHealthComplete());
  }

  void setCurrentPage(int value) => currentPage(value);

  void nextPage(BuildContext context) {
    FocusScope.of(context).unfocus();
    pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previosPage() {
    pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  var selectedType = PetType.none.obs;

  void selectType(PetType type) {
    selectedType(selectedType() == type ? PetType.none : type);
    selectedWeight.value = null;
    dateOfBirthController.text = '';
    petNameController.text = '';
    selectedBreed.value = null;
    selectedSex.value = null;
    // selectedSize = null;
    // selectedsFood.clear();

    // healthCondition = null;
    // healthPlan = null;
    // selectedsPersonality.clear();
  }

  //TODO tela detalhes do pet
  TextEditingController petNameController = TextEditingController();

  final petNameError = Rxn<String>();

  void validatePetNameField() {
    petNameError.value = validatePetName(petNameController.text);
  }

  TextEditingController dateOfBirthController = TextEditingController();

  final dateOfBirthError = Rxn<String>();

  void validateDateOfBirthField() {
    dateOfBirthError.value = validateDate(dateOfBirthController.text);
  }

  var selectedSex = Rxn<PetSex>();

  void selectSex(PetSex? sex) => selectedSex(sex);

  List<PetWeight> get listWeights {
    switch (selectedType()) {
      case PetType.dog:
        return DogWeight.values;
      case PetType.cat:
        return CatWeight.values;
      default:
        return [];
    }
  }

  var selectedWeight = Rxn<PetWeight>();

  void selectWeight(PetWeight? weight) => selectedWeight(weight);

  var selectedBreed = Rxn<BreedResponse>();

  void selectBreed(BreedResponse breed) => selectedBreed(breed);

  final loadingBreeds = false.obs;

  void setLoadingBreeds(bool value) => loadingBreeds(value);

  List<BreedResponse> breeds = [];

  Future<void> getBreedNow() async {
    setLoadingBreeds(true);
    await getBreeds();
    setLoadingBreeds(false);
  }

  Future<void> getBreeds() async {
    final result = await _newPetRepository.getBreeds(
      BreedRequest(type: selectedType()),
    );
    if (result.success) {
      breeds.addAll(result.result!);
      return;
    }
    showError(message: 'Erro ao buscar raças');
  }

  bool get detailsComplete {
    final allFieldsFilled = petNameController.text.isNotEmpty &&
        dateOfBirthController.text.isNotEmpty;
    final hasError = petNameError.value != '' || dateOfBirthError.value != '';

    final allSelect = [
      selectedSex(),
      selectedWeight(),
      selectedBreed(),
    ].every((select) => select != null);

    return allFieldsFilled && allSelect && !hasError;
  }

  var selectedSize = Rxn<PetSize>();

  void selectSize(PetSize size) {
    selectedSize.value = selectedSize() == size ? null : size;
  }

  List<PetSize> get availableSizes {
    switch (selectedType()) {
      case PetType.dog:
        return DogSize.values;
      case PetType.cat:
        return CatSize.values;
      case PetType.none:
        return [];
    }
  }

  var foodOptions = PetFood.options.obs;
  var selectedFoods = <String>[].obs;
  var petFoodController = TextEditingController();
  var petFoodError = RxnString();

  bool containsString(List<String> list, String query) {
    return list.any((item) => item.toLowerCase() == query.toLowerCase());
  }

  void addFoodInList(String food) {
    if (!selectedFoods.contains(food)) {
      selectedFoods.add(food);
      //foodOptions.add(food);
    }
  }

  void removeFoodInList(String food) {
    selectedFoods.remove(food);
  }

  void addCustomFood() {
    final food = petFoodController.text.trim();
    if (food.isNotEmpty && !selectedFoods.contains(food)) {
      foodOptions.add(food);
      selectedFoods.add(food);
      petFoodController.clear();
    } else {
      showError(message: "Esse alimento já foi adicionado ou é inválido.");
    }
  }

  void validatePetFoodField() {
    petFoodError.value = validatePetFood(petFoodController.text);
  }

  String? validatePetFood(String text) {
    return text.isEmpty ? "O nome do alimento não pode estar vazio." : null;
  }

  bool get foodComplete {
    final isTextValid =
        petFoodError.value == null && petFoodController.text.isNotEmpty;
    final isListValid = selectedFoods.isNotEmpty;
    return isTextValid || isListValid;
  }

  var healthPlan = RxnBool();
  var healthCondition = RxnBool();
  var petConditionController = TextEditingController();
  var petConditionError = RxnString();

  final healthPlanSelected = Rxn<HealthPlanResponse>();

  void setSelectedPlan(HealthPlanResponse value) => healthPlanSelected(value);

  void setHealthPlan(bool value) {
    healthPlan.value = value;
    healthComplete(checkHealthComplete());
  }

  void setHealthCondition(bool value) {
    healthCondition.value = value;
    healthComplete(checkHealthComplete());
  }

  void validatePetConditionField() {
    petConditionError.value = validatePetName(petConditionController.text);
  }

  void setHealthConditionText(String value) {
    healthConditionName(value);
    validatePetConditionField();
    healthComplete(checkHealthComplete());
  }

  bool checkHealthComplete() {
    if (healthPlan.value == null) return false;
    if (healthCondition.value == null) return false;
    if (healthPlan.value == true && selectedHealthPlan.value == null) {
      return false;
    }
    if (healthCondition.value == true) {
      if (healthConditionName.value.isEmpty) {
        return false;
      }
      if (petConditionError.value == null) {
        return false;
      }
    }
    return true;
  }

  var selectedsPersonality = <PetPersonality>[].obs;
  var loadingCreatePet = false.obs;

  void addPersonalityInList(PetPersonality personality) {
    selectedsPersonality.clear();
    selectedsPersonality.add(personality);
  }

  void removePersonalityInList(PetPersonality personality) {
    selectedsPersonality.remove(personality);
  }

  void close() => _navigationService.back();

  Future<void> createPet() async {
    isLoading(true);

    final request = CreatePetRequest(
      type: selectedType(),
      name: petNameController.text,
      weight: selectedWeight()!,
      birthDate: parseDateToUtc(dateOfBirthController.text),
      sex: selectedSex()!,
      breed: selectedBreed()!,
      size: selectedSize()!,
      foods: selectedFoods,
      healthPlan: healthPlan()!,
      healthCondition: healthCondition() ?? false,
      personalitys: selectedsPersonality,
      healthPlanId: selectedHealthPlan()?.id != '' && healthPlan() == true
          ? selectedHealthPlan()?.id
          : null,
      healthConditionName:
          healthCondition() == true ? healthConditionName() : null,
      healthSeverity: healthCondition() == true
          ? severityHealthFromString(selectedSeverity()).name
          : null,
      healthDate: healthCondition() == true ? selectedDate() : null,
    );
    final response = await _newPetRepository.createPet(request);
    isLoading(false);
    if (response.success) {
      // _navigationService.offAllNamed(HomeRoutes.home, arguments: true);
      // _navigationService.offAllNamed(BiometricsRoutes.biometrics,
      //     arguments: response.result);
      _navigationService.offAllNamed(BiometricRoutes.petImage,
          arguments: response.result);
      showSuccess(message: 'Pet criado com sucesso');
    } else {
      showError(message: 'Erro ao criar pet');
    }
  }

  void goToHome() {
    _navigationService.offAllNamed(HomeRoutes.home);
  }
}
