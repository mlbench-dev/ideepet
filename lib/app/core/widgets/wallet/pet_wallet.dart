import 'package:flutter/material.dart';
import 'package:idee_pet/app/core/models/pet.entity.dart';
import 'package:idee_pet/app/core/models/profile.entity.dart';
import 'package:idee_pet/app/modules/home/widgets/wallet/back.dart';
import 'package:idee_pet/app/modules/home/widgets/wallet/front.dart';
import 'package:idee_pet/app/core/core_old/colors.dart';
import 'package:idee_pet/app/core/core_old/widgets/text_styles.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get/get.dart';

class WalletPet extends StatefulWidget {
  final Pet pet;
  final Profile profile;
  const WalletPet({
    super.key,
    required this.pet,
    required this.profile,
  });

  @override
  State<WalletPet> createState() => _WalletPetState();
}

class _WalletPetState extends State<WalletPet> {
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    double heightScreen = MediaQuery.of(context).size.height;
    double widthScreen = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: Get.back,
                        icon: Icon(Icons.close),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    children: [
                      WalletFront(
                        pet: widget.pet,
                        profile: widget.profile,
                        heightScreen: heightScreen,
                        widthScreen: widthScreen,
                      ),
                      WalletBack(
                        pet: widget.pet,
                        profile: widget.profile,
                        heightScreen: heightScreen,
                        widthScreen: widthScreen,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, color: AppColors.cardColor),
                          Text(
                            'Os dados do seu pet estão seguros em nosso cofre',
                            style: AppTextStyles.poppinsMedium(
                                    fontSize: 10, color: AppColors.background)
                                .style,
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: 2,
                        effect: const ExpandingDotsEffect(
                          activeDotColor: AppColors.primary,
                          dotColor: Colors.grey,
                          dotHeight: 8,
                          dotWidth: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        color: AppColors.blueId,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock,
                  color: AppColors.primary,
                  size: 10,
                ),
                Text('Identificação única do pet',
                    style: AppTextStyles.poppinsMedium(
                            color: AppColors.primary, fontSize: 12)
                        .style),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
