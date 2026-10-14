import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/core/services/osm_service.dart';
import 'package:idee_pet/app/routes/capture_image_routes.dart';
import 'package:idee_pet/lib.dart';
import 'package:image_picker/image_picker.dart';

class OnboardingController extends GetxController {
  final OnboardingRepository _repository;
  final ViaCepService _viaCepService;
  final NavigationService _navigationService;
  final AppStateService _appStateService;
  final AuthService _authService;
  final OsmService _osmService;

  late final bool isChanging;

  OnboardingController(
    this._repository,
    this._viaCepService,
    this._navigationService,
    this._appStateService,
    this._authService,
    this._osmService,
  );

  final FocusNode numberFoccusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    // Valor padrão
    bool changing = false;
    int initialPage = 0;

    // ?? Compatível com bool antigo
    if (args is bool) {
      changing = args;
    }

    // ?? Novo formato (mapa)
    if (args is Map) {
      changing = args['isChanging'] ?? false;
      initialPage = args['initialPage'] ?? 0;
    }

    isChanging = changing;

    pageController = PageController(initialPage: initialPage);
    page.value = initialPage;

    if (isChanging) {
      _fillInputs();
    }
  }

  bool hasChanges() {
    return nameController.text != initialValues['name'] ||
        phoneController.text != initialValues['phone'] ||
        zipCodeController.text != initialValues['zip'] ||
        addressController.text != initialValues['address'] ||
        cityController.text != initialValues['city'] ||
        stateController.text != initialValues['state'] ||
        numberController.text != initialValues['number'] ||
        neightbourhoodController.text != initialValues['neight'] ||
        complementController.text != initialValues['complement'];
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController complementController = TextEditingController();
  TextEditingController neightbourhoodController = TextEditingController();

  void _fillInputs() {
    nameController.text = _appStateService.profile().name;
    emailController.text = _appStateService.profile().email;
    phoneController.text = _appStateService.profile().phone?.substring(3) ?? '';
    addressController.text = _appStateService.profile().addressStreet ?? '';
    zipCodeController.text = _appStateService.profile().addressCep ?? '';
    cityController.text = _appStateService.profile().addressCity ?? '';
    stateController.text = _appStateService.profile().addressState ?? '';
    numberController.text = _appStateService.profile().addressNumber ?? '';
    complementController.text =
        _appStateService.profile().addressComplement ?? '';
    neightbourhoodController.text =
        _appStateService.profile().addressNeighborhood ?? '';
    profileImageUrl.value = _appStateService.profile().imageUrl ?? '';
    initialValues = {
      'name': nameController.text,
      'phone': phoneController.text,
      'zip': zipCodeController.text,
      'address': addressController.text,
      'city': cityController.text,
      'state': stateController.text,
      'number': numberController.text,
      'neight': neightbourhoodController.text,
      'complement': complementController.text,
    };
    validate();
  }

  final nameError = ''.obs;
  final emailError = ''.obs;
  final passwordError = ''.obs;
  final phoneError = ''.obs;
  final addressError = ''.obs;
  final numberError = ''.obs;
  final zipCodeError = ''.obs;
  final cityError = ''.obs;
  final stateError = ''.obs;

  final code = ''.obs;

  final canProceed = false.obs;
  final isLoading = false.obs;

  final loadingAddress = false.obs;

  final canManualEdit = false.obs;
  Map<String, String?> initialValues = {};

  void validateNameField() {
    nameError(validateName(nameController.text));
    validate();
  }

  void validateEmailField() {
    emailError(validateEmail(emailController.text));
    validate();
  }

  void validatePasswordField() {
    isChanging
        ? passwordError('')
        : passwordError(validatePassword(passwordController.text));
    validate();
  }

  void validatePhoneField() {
    phoneError(validatePhone(phoneController.text));
    validate();
  }

  void validateAddressField() {
    addressError(validateAddress(addressController.text));
    validate();
  }

  void validateNumberField() {
    numberError(validateNumber(numberController.text));
    validate();
  }

  void validateZipCodeField() {
    zipCodeError(validateZipCode(zipCodeController.text));
    validate();
  }

  void validateCityField() {
    cityError(validateCity(cityController.text));
    validate();
  }

  void validateStateField() {
    stateError(validateState(stateController.text));
    validate();
  }

  void validate() {
    if (isChanging) {
      final hasTextChanges = hasChanges();
      final hasImageChange = profileImage.value != null;

      canProceed(hasTextChanges || hasImageChange);
      return;
    }

    // 🆕 Criação
    final result = nameError() == '' &&
        emailError() == '' &&
        passwordError() == '' &&
        nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;

    canProceed(result);
  }

  final loadingCreate = false.obs;

  bool forwardScreenConfirmCode = false;

  Future<void> validateCep(String cep) async {
    if (cep.length == 9) {
      loadingAddress(true);
      final result = await _viaCepService.getAddress(cep);
      if (result != null) {
        addressController.text = result.logradouro;
        cityController.text = result.localidade;
        stateController.text = result.uf;
        neightbourhoodController.text = result.bairro;
        loadingAddress(false);
        canManualEdit(false);
        validate();

        if (result.logradouro == '' ||
            result.localidade == '' ||
            result.uf == '') {
          canManualEdit(true);
        }

        numberFoccusNode.requestFocus();

        return;
      }
      addressController.text = '';
      cityController.text = '';
      stateController.text = '';
      showError(message: 'CEP não encontrado!');
      canManualEdit(true);
      loadingAddress(false);
      validate();
    }
  }

  Future<void> next() async {
    if (!canProceed()) return;

    FocusManager.instance.primaryFocus?.unfocus();

    // ✏️ EDIÇÃO DE CONTA → nunca navega
    if (isChanging) {
      final hasTextChanges = hasChanges();
      final hasImageChange = profileImage.value != null;

      if (!hasTextChanges && !hasImageChange) {
        showError(message: 'Nenhuma alteração realizada');
        return;
      }

      await _updateUser();
      return;
    }

    // 🆕 NOVA CONTA → onboarding normal
    if (page.value == 0) {
      changePage(1);
      return;
    }

    await _createUser();
  }

  Future<void> _updateUser() async {
    loadingCreate(true);

    final request = UpdateUserRequest();

    if (profileImage.value != null) {
      request.image = profileImage.value;
    }

    if (nameController.text != initialValues['name']) {
      request.name = nameController.text;
    }

    if (phoneController.text != initialValues['phone']) {
      request.phone = removePhoneMask(phoneController.text);
    }

    if (zipCodeController.text != initialValues['zip']) {
      request.addressZipCode = zipCodeController.text;
    }

    if (addressController.text != initialValues['address']) {
      request.addressStreet = addressController.text;
    }

    if (cityController.text != initialValues['city']) {
      request.addressCity = cityController.text;
    }

    if (stateController.text != initialValues['state']) {
      request.addressState = stateController.text;
    }

    if (numberController.text != initialValues['number']) {
      request.addressNumber = numberController.text;
    }

    if (neightbourhoodController.text != initialValues['neight']) {
      request.neightbourhood = neightbourhoodController.text;
    }

    if (complementController.text != initialValues['complement']) {
      request.addressComplement = complementController.text;
    }

    /// ?? Coordenadas só se endereço mudou
    final addressChanged = request.addressStreet != null ||
        request.addressCity != null ||
        request.addressState != null ||
        request.addressNumber != null ||
        request.addressZipCode != null;

    if (addressChanged) {
      final osmResponse = await _osmService.getCoordinates(
        OsmRequest(
          address: addressController.text,
          city: cityController.text,
          state: stateController.text,
          number: numberController.text,
          postalCode: zipCodeController.text,
        ),
      );

      if (osmResponse != null) {
        request.addressLat = osmResponse.lat.toString();
        request.addressLong = osmResponse.lon.toString();
      }
    }

    /// ?? Se nada mudou, nem chama API
    if (request.toFormData().fields.isEmpty &&
        request.toFormData().files.isEmpty) {
      loadingCreate(false);
      _navigationService.back();
      return;
    }

    final profile = await _authService.updateUserData(request);

    if (profile != null) {
      _appStateService.setProfile(profile);
      _navigationService.back();
      showSuccess(message: 'Dados atualizados com sucesso!');
      return;
    }

    loadingCreate(false);
    showError();
  }

  Future<void> _createUser() async {
    loadingCreate(true);
    final request = CreateUserRequest(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      phone: phoneController.text == ''
          ? null
          : removePhoneMask(phoneController.text),
      addressStreet:
          addressController.text == '' ? null : addressController.text,
      addressNumber: numberController.text == '' ? null : numberController.text,
      addressZipCode:
          zipCodeController.text == '' ? null : zipCodeController.text,
      addressCity: cityController.text == '' ? null : cityController.text,
      addressState: stateController.text == '' ? null : stateController.text,
      addressComplement:
          complementController.text == '' ? null : complementController.text,
      neightbourhood: neightbourhoodController.text == ''
          ? null
          : neightbourhoodController.text,
      influencerId: BranchService.referredInfluencerId,
      image: profileImage.value,
    );
    try {
      OsmResponse? osmResponse;
      if (addressController.text != '' &&
          cityController.text != '' &&
          stateController.text != '' &&
          numberController.text != '' &&
          zipCodeController.text != '') {
        osmResponse = await _osmService.getCoordinates(
          OsmRequest(
            address: addressController.text,
            city: cityController.text,
            state: stateController.text,
            number: numberController.text,
            postalCode: zipCodeController.text,
          ),
        );
      }

      if (osmResponse != null) {
        request.addressLat = osmResponse.lat.toString();
        request.addressLong = osmResponse.lon.toString();
      }
    } catch (e) {
      BugTracking().send('erro ao pegar coordenadas', e);
    }

    final response = await _repository.createUser(request);
    if (response.result != null && response.success) {
      await BranchService.clearInfluencer();
      showSuccess(message: 'Usuário criado com sucesso!');
      code(response.result?.code);
      await _navigationService.toNamed(OtpRoutes.otp, arguments: code());
      return;
    }
    // TODO: verificar se o erro é 422 (usuário já cadastrado) e redirecionar para a tela de login
    // if (response.statusCode == 422) {
    //   _navigationService.offAllNamed(LoginRoutes.login);
    // }
    loadingCreate(false);
    showError(message: response.errorMessages?.first);
  }

  PageController pageController = PageController(initialPage: 0);
  RxInt page = 0.obs;

  void changePage(int index) {
    page(index);
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  final profileImage = Rxn<File>();

  void setProfileImage(File image) {
    profileImage.value = image;
  }

  final RxString profileImageUrl = ''.obs;

  Future<void> goToCaptureImage({
    required Function(String path) onImageCaptured,
  }) async {
    await Get.toNamed(
      CaptureImageRoutes.captureImage,
      arguments: {
        'onImageCaptured': onImageCaptured,
      },
    );
  }

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

  void clearProfileImage() {
    profileImage.value = null;
  }
}
