import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/core/core_old/colors.dart';
import 'package:idee_pet/app/core/core_old/helps/cep_input_formater.dart';
import 'package:idee_pet/app/core/core_old/widgets/buttons.dart';
import 'package:idee_pet/app/core/core_old/widgets/text_styles.dart';
import 'package:idee_pet/app/core/core_old/widgets/textfield.dart';
import 'package:idee_pet/app/modules/onboarding/onboarding_controller.dart';

class OnboardingProfileStep1 extends StatelessWidget {
  const OnboardingProfileStep1({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return Obx(
      () {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      icon: CircleAvatar(
                        backgroundColor: AppColors.greyWhite,
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.primary,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Cadastro Pessoal',
                      style: AppTextStyles.title(fontSize: 34).style,
                    ),
                    Text(
                      controller.isChanging
                          ? 'Mantenha seu cadastro atualizado e\naproveite todos os benefícios.'
                          : 'Crie sua conta e aproveite todos\nos benefícios.',
                      style: AppTextStyles.subtitle().style,
                    ),
                    SizedBox(height: 20),
                    AppTextField(
                      controller: controller.nameController,
                      textInputAction: TextInputAction.next,
                      bordercolor: Colors.transparent,
                      cursorColor: AppColors.primary,
                      hintText: 'Nome',
                      maxLines: 1,
                      erroText: controller.nameError() != ''
                          ? controller.nameError()
                          : null,
                      onChanged: (_) => controller.validateNameField(),
                    ),
                    SizedBox(height: 20),
                    Visibility(
                      visible: !controller.isChanging,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: controller.emailController,
                            textInputAction: TextInputAction.next,
                            bordercolor: Colors.transparent,
                            cursorColor: AppColors.primary,
                            hintText: 'E-mail',
                            maxLines: 1,
                            erroText: controller.emailError() != ''
                                ? controller.emailError()
                                : null,
                            onChanged: (_) => controller.validateEmailField(),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    if (!controller.isChanging) ...[
                      AppTextField(
                        controller: controller.passwordController,
                        textInputAction: TextInputAction.next,
                        bordercolor: Colors.transparent,
                        cursorColor: AppColors.primary,
                        hintText: 'Senha',
                        maxLines: 1,
                        hidePassword: true,
                        erroText: controller.passwordError() != ''
                            ? controller.passwordError()
                            : null,
                        onChanged: (_) => controller.validatePasswordField(),
                      ),
                      SizedBox(height: 20),
                    ],
                    AppTextField(
                      keyboardType: TextInputType.number,
                      controller: controller.phoneController,
                      textInputAction: TextInputAction.next,
                      bordercolor: Colors.transparent,
                      cursorColor: AppColors.primary,
                      hintText: 'Telefone',
                      maxLines: 1,
                      erroText: controller.phoneError() != ''
                          ? controller.phoneError()
                          : null,
                      onChanged: (_) => controller.validatePhoneField(),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TelefoneInputFormatter(),
                      ],
                    ),
                    SizedBox(height: 20),
                    AppTextField(
                      enabled: !controller.loadingAddress.isTrue,
                      keyboardType: TextInputType.number,
                      controller: controller.zipCodeController,
                      textInputAction: TextInputAction.next,
                      bordercolor: Colors.transparent,
                      cursorColor: AppColors.primary,
                      hintText: 'Cep',
                      maxLines: 1,
                      erroText: controller.zipCodeError() != ''
                          ? controller.zipCodeError()
                          : null,
                      onChanged: (value) => controller.validateCep(value),
                      inputFormatters: [CepInputFormatters()],
                    ),
                    SizedBox(height: 20),
                    controller.loadingAddress.isTrue
                        ? Column(
                            children: [
                              SizedBox(height: 10),
                              LinearProgressIndicator(),
                              SizedBox(height: 30),
                            ],
                          )
                        : SizedBox(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 3,
                          child: AppTextField(
                            controller: controller.addressController,
                            textInputAction: TextInputAction.done,
                            bordercolor: Colors.transparent,
                            cursorColor: AppColors.primary,
                            hintText: 'Endereço',
                            maxLines: 1,
                            erroText: controller.addressError() != ''
                                ? controller.addressError()
                                : null,
                            onChanged: (_) => controller.validateAddressField(),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          flex: 1,
                          child: AppTextField(
                            keyboardType: TextInputType.number,
                            controller: controller.numberController,
                            textInputAction: TextInputAction.next,
                            bordercolor: Colors.transparent,
                            cursorColor: AppColors.primary,
                            hintText: 'Número',
                            maxLines: 1,
                            focusNode: controller.numberFoccusNode,
                            erroText: controller.numberError() != ''
                                ? controller.numberError()
                                : null,
                            onChanged: (_) => controller.validateNumberField(),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    AppTextField(
                      controller: controller.complementController,
                      textInputAction: TextInputAction.done,
                      bordercolor: Colors.transparent,
                      cursorColor: AppColors.primary,
                      hintText: 'Complemento',
                      maxLines: 1,
                      onChanged: (_) => controller.validate(),
                    ),
                    SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 3,
                          child: AppTextField(
                            enabled: controller.canManualEdit(),
                            controller: controller.cityController,
                            textInputAction: TextInputAction.done,
                            bordercolor: Colors.transparent,
                            cursorColor: AppColors.primary,
                            hintText: 'Cidade',
                            maxLines: 1,
                            onChanged: (_) => controller.validateCityField(),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          flex: 1,
                          child: AppTextField(
                            enabled: controller.canManualEdit(),
                            controller: controller.stateController,
                            textInputAction: TextInputAction.done,
                            bordercolor: Colors.transparent,
                            cursorColor: AppColors.primary,
                            hintText: 'Estado',
                            maxLines: 1,
                            onChanged: (_) => controller.validateStateField(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
            Obx(
              () {
                return CustomButton.filled(
                  action: controller.canProceed.isTrue
                      ? () {
                          FocusScope.of(context).unfocus();
                          controller.next();
                        }
                      : null,
                  title: Text(controller.isChanging ? 'Salvar' : 'Prosseguir',
                      style: AppTextStyles.poppinsSemiBold(
                        color: AppColors.background,
                      ).style),
                );
              },
            ),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }
}
