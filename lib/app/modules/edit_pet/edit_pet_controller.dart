import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/modules/new_pet/repository/dtos/request/breed_request.dart';
import 'package:idee_pet/app/routes/biometric_routes.dart';
import 'package:idee_pet/app/routes/capture_image_routes.dart';
import 'package:idee_pet/app/routes/transfer_pet_routes.dart';
import 'package:image_picker/image_picker.dart';

class EditPetController extends GetxController {
  final NavigationService _navigationService;
  final EditPetRepository _editPetRepository;
  EditPetController(
    this._navigationService,
    this._editPetRepository,
  );
  late Pet pet;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      pet = Get.arguments as Pet;
      selectedsPersonality(pet.personalitys);
      foodOptions.addAll(getExclusiveItems(
        PetFood.options,
        pet.foods,
      ));
      selectedFoods.addAll(pet.foods.map((food) => food));
      selectedType(pet.type);
      selectedSex(pet.petSex);
      petNameController.text = pet.name;
      selectedWeight(pet.weight);
      if (pet.breed != null) {
        selectBreed(BreedResponse(id: pet.breed!.id, name: pet.breed!.name));
      }
      getBreeds();
      dateOfBirthController.text = formatDayMonthYearFull(pet.birthDate);
      selectSize(pet.size!);
      return;
    }
    _navigationService.offAllNamed(HomeRoutes.home);
    showError(message: 'Pet não encontrado');
  }

  bool containsString(List<String> list, String query) {
    return list.any((item) => item.toLowerCase() == query.toLowerCase());
  }

  var foodOptions = PetFood.options.obs;

  var selectedFoods = <String>[].obs;

  var petFoodController = TextEditingController();
  var petFoodError = RxnString();

  List<String> getExclusiveItems(List<String> listA, List<String> listB) {
    return listB.where((item) => !listA.contains(item)).toList();
  }

  void addFoodInList(String food) {
    if (!selectedFoods.contains(food)) {
      //foodOptions.add(food);
      selectedFoods.add(food);
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

  bool get foodComplete {
    final isTextValid =
        petFoodError.value == null && petFoodController.text.isNotEmpty;
    final isListValid = selectedFoods.isNotEmpty;

    final originalFoods = pet.foods.map((food) => food.toLowerCase()).toSet();

    final currentFoods =
        selectedFoods.map((food) => food.trim().toLowerCase()).toSet();

    final isModified = !setEquals(originalFoods, currentFoods);

    return (isTextValid || isListValid) && isModified;
  }

  final isLoading = false.obs;

  Future<void> editFood() async {
    isLoading(true);
    final request = FoodRequest(
      foods: selectedFoods,
      id: pet.id,
    );
    final response = await _editPetRepository.updateFoods(request);
    isLoading(false);
    if (response.success) {
      _navigationService.offAllNamed(HomeRoutes.home, arguments: true);
      showSuccess(message: 'Alimentos alterados com sucesso!');
    } else {
      showError(message: 'Erro ao alterar alimentos');
    }
  }

  void navigatorPop() {
    Get.back();
  }

  var selectedsPersonality = <PetPersonality>[].obs;

  void addPersonalityInList(PetPersonality personality) {
    selectedsPersonality.clear();
    selectedsPersonality.add(personality);
  }

  void removePersonalityInList(PetPersonality personality) {
    selectedsPersonality.remove(personality);
  }

  Future<void> editPersonality() async {
    isLoading(true);
    final request = PersonalityRequest(
      personalitys: selectedsPersonality,
      id: pet.id,
    );
    final response = await _editPetRepository.updatePersonality(request);
    isLoading(false);
    if (response.success) {
      _navigationService.offAllNamed(HomeRoutes.home, arguments: true);
      showSuccess(message: 'Personalidade com sucesso!');
    } else {
      showError(message: 'Erro ao alterar personalidade');
    }
  }

  TextEditingController petNameController = TextEditingController();

  final petNameError = Rxn<String>();

  void validatePetNameField() {
    petNameError(validatePetName(petNameController.text));
    updateDetailsComplete();
  }

  TextEditingController dateOfBirthController = TextEditingController();

  final dateOfBirthError = Rxn<String>();

  void validateDateOfBirthField() {
    dateOfBirthError(validateDate(dateOfBirthController.text));
    updateDetailsComplete();
  }

  var selectedType = PetType.none.obs;

  var selectedSex = Rxn<PetSex>();

  void selectSex(PetSex? sex) {
    selectedSex(sex);
    updateDetailsComplete();
  }

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

  void selectWeight(PetWeight? weight) {
    selectedWeight(weight);
    updateDetailsComplete();
  }

  var selectedBreed = Rxn<BreedResponse>();

  void selectBreed(BreedResponse breed) {
    selectedBreed(breed);
    updateDetailsComplete();
  }

  final loadingBreeds = false.obs;

  void setLoadingBreeds(bool value) => loadingBreeds(value);

  List<BreedResponse> breeds = [];

  Future<void> getBreedNow() async {
    setLoadingBreeds(true);
    await getBreeds();
    setLoadingBreeds(false);
  }

  Future<void> getBreeds() async {
    final result = await _editPetRepository.getBreeds(
      BreedRequest(type: selectedType()),
    );
    if (result.success) {
      breeds.addAll(result.result!);
      return;
    }
    showError(message: 'Erro ao buscar raças');
  }

  final RxBool detailsComplete = false.obs;

  void updateDetailsComplete() {
    final allFieldsFilled = petNameController.text.isNotEmpty &&
        dateOfBirthController.text.isNotEmpty;
    final hasError = (petNameError.value != '' && petNameError.value != null) ||
        (dateOfBirthError.value != '' && dateOfBirthError.value != null);

    final allSelect = [
      selectedSex(),
      selectedWeight(),
      selectedBreed(),
    ].every((select) => select != null);

    final currentPetName = petNameController.text.trim();
    final initialPetName = pet.name.trim();
    final currentBirthDate = dateOfBirthController.text.trim();
    final initialBirthDate = formatDayMonthYearFull(pet.birthDate).trim();

    // print("Comparando petName: '$currentPetName' com '$initialPetName'");
    // print("São iguais? \ ${currentPetName == initialPetName}");
    // print("Comparando birthDate: '$currentBirthDate' com '$initialBirthDate'");
    // print("São iguais? \ ${currentBirthDate == initialBirthDate}");

    final hasChanges = currentPetName != initialPetName ||
        currentBirthDate != initialBirthDate ||
        selectedSex() != pet.petSex ||
        selectedWeight() != pet.weight ||
        selectedBreed()?.id != pet.breed?.id;

    // print("allFieldsFilled: \ $allFieldsFilled");
    // print("hasError: \ ${!hasError}");
    // print("allSelect: \ $allSelect");
    // print("hasChanges: \ $hasChanges");

    detailsComplete.value =
        allFieldsFilled && allSelect && !hasError && hasChanges;
  }

  Future<void> editDetails() async {
    isLoading(true);
    final currentPetName = petNameController.text.trim();
    final initialPetName = pet.name.trim();
    final currentBirthDate = parseDateToUtc(dateOfBirthController.text);
    final initialBirthDate = pet.birthDate;
    final request = DetailsRequest(
      id: pet.id,
      petName: currentPetName != initialPetName ? currentPetName : null,
      birthDate: currentBirthDate != initialBirthDate ? currentBirthDate : null,
      petSex: selectedSex() != pet.petSex ? selectedSex() : null,
      weight: selectedWeight() != pet.weight ? selectedWeight() : null,
      breed: selectedBreed()?.id != pet.breed?.id ? selectedBreed() : null,
    );

    final response = await _editPetRepository.updateDetails(request);
    isLoading(false);

    if (response.success) {
      _navigationService.offAllNamed(HomeRoutes.home, arguments: true);
      showSuccess(message: 'Detalhes atualizados com sucesso!');
    } else {
      showError(message: 'Erro ao atualizar detalhes');
    }
  }

  var selectedSize = Rxn<PetSize>();

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

  void selectSize(PetSize size) {
    selectedSize.value = selectedSize() == size ? null : size;
  }

  Future<void> editSize() async {
    isLoading(true);
    final request = SizeRequest(
      id: pet.id,
      petSize: selectedSize()!,
    );

    final response = await _editPetRepository.updateSize(request);
    isLoading(false);

    if (response.success) {
      _navigationService.offAllNamed(HomeRoutes.home, arguments: true);
      showSuccess(message: 'Atualizado com sucesso!');
    } else {
      showError(message: 'Erro ao atualizar');
    }
  }

  void goToPersonality() {
    _navigationService.toNamed(EditPetRoutes.editPersonality, arguments: pet);
  }

  void goToEditFoodPet() {
    _navigationService.toNamed(EditPetRoutes.editFood, arguments: pet);
  }

  void goToBiometry() {
    // _navigationService.toNamed(BiometricRoutes.biometric, arguments: pet);
    _navigationService.toNamed(BiometricRoutes.guide, arguments: pet);
  }

  void goToImage() {
    _navigationService.toNamed(BiometricRoutes.image, arguments: pet);
  }

  void goToTransferPet() {
    _navigationService.toNamed(TransferPetRoutes.transferPet);
  }

  Future<void> deletePet() async {
    final response = await _editPetRepository.deletePet(pet.id);
    if (response.success) {
      _navigationService.offAllNamed(HomeRoutes.home, arguments: true);
      showSuccess(message: 'Pet excluido com sucesso!');
    } else {
      showError(message: 'Erro ao excluir pet');
    }
  }

  // Lógica da Foto de Perfil do Pet
  // ===========================================================================

  var petProfile = Rx<File?>(null);
  var loadingPetProfile = false.obs;
  void setLoadingPetProfile(bool value) => loadingPetProfile.value = value;
  void attProgress(double value) => progress.value = value;
  var progress = 0.0.obs;

  void setProgressPetProfile(double value) => progressPetProfile.value = value;
  RxDouble progressPetProfile = 0.0.obs;
  Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();

    try {
      final pickedFile =
          await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
      showError(
          message:
              "Não foi possível acessar a ${source == ImageSource.camera ? 'câmera' : 'galeria'}. Verifique as permissões.");
    }
    return null;
  }

  Future<void> goToCaptureImage({
    required void Function(String imagePath) onImageCaptured,
  }) async {
    await _navigationService.toNamed(
      CaptureImageRoutes.captureImage,
      arguments: {
        'onImageCaptured': onImageCaptured,
      },
    );
  }

  void updatePetProfile(File? image) {
    if (image != null) {
      petProfile.value = image;
    }
  }

  Future<void> sendPetProfile() async {
    if (petProfile.value == null) {
      showError(message: "Selecione uma imagem de perfil.");
      return;
    }

    setLoadingPetProfile(true);
    progress(0.0);

    final request = PetProfileRequest(
      id: pet.id,
      image: petProfile.value!,
      onProgress: setProgressPetProfile,
    );

    try {
      final response = await _editPetRepository.sendPetProfile(request);

      if (response.success) {
        _navigationService.offAllNamed(HomeRoutes.home, arguments: true);
      } else {
        showError(message: 'Erro ao enviar a foto do pet');
      }
    } catch (e) {
      print("Erro em sendPetProfile: $e");
      showError(message: 'Ocorreu um erro ao enviar a foto.');
    } finally {
      setLoadingPetProfile(false);
      progress(0.0); // Reseta progresso
    }
  }
}
