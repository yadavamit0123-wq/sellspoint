import 'package:eClassify/data/cubits/ai/generate_description_cubit.dart';
import 'package:eClassify/data/cubits/custom_field/fetch_custom_fields_cubit.dart';
import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/data/model/item/ad_posting_step.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_ad_type_step.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_basic_details_step.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_category_step.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_custom_fields_step.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_form_buttons.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_header.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// In-app wizard through basics (+ optional custom fields), then legacy photos/location.
class AdPostingInAppScreen extends StatefulWidget {
  const AdPostingInAppScreen({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AdPostingCubit()),
          BlocProvider(create: (_) => GenerateDescriptionCubit()),
          BlocProvider(create: (_) => FetchCustomFieldsCubit()),
          BlocProvider(
            create: (_) => CategoryBrowsingCubit()..start(),
          ),
        ],
        child: AdPostingInAppScreen(
          arguments: routeSettings.arguments as Map<String, dynamic>?,
        ),
      ),
    );
  }

  @override
  State<AdPostingInAppScreen> createState() => _AdPostingInAppScreenState();
}

class _AdPostingInAppScreenState extends State<AdPostingInAppScreen> {
  final PageController _pageController = PageController();
  final AdPostingStepController _stepController = AdPostingStepController();

  @override
  void dispose() {
    _pageController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  Widget _stepFor(AdPostingStep step) {
    switch (step) {
      case AdPostingStep.adType:
        return const AdPostingAdTypeStep();
      case AdPostingStep.category:
        return AdPostingCategoryStep(extraArguments: widget.arguments);
      case AdPostingStep.baseDetails:
        return AdPostingBasicDetailsStep(extraArguments: widget.arguments);
      case AdPostingStep.customFields:
        return AdPostingCustomFieldsStep(extraArguments: widget.arguments);
    }
  }

  void _onBack(AdPostingState state) {
    switch (state.activeStep) {
      case AdPostingStep.customFields:
      case AdPostingStep.baseDetails:
        context.read<AdPostingCubit>().previousStep();
        return;
      case AdPostingStep.category:
        final browsing = context.read<CategoryBrowsingCubit>();
        if (browsing.canPopLevel()) {
          browsing.popLevel();
          return;
        }
        context.read<AdPostingCubit>().previousStep();
        return;
      case AdPostingStep.adType:
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdPostingStepControllerProvider(
      controller: _stepController,
      child: MultiBlocListener(
        listeners: [
          BlocListener<AdPostingCubit, AdPostingState>(
            listenWhen: (previous, current) =>
                previous.activeStep != current.activeStep ||
                previous.steps.length != current.steps.length,
            listener: (context, state) {
              final index = state.steps.indexOf(state.activeStep);
              if (_pageController.hasClients &&
                  _pageController.page?.round() != index) {
                _pageController.jumpToPage(index);
              }
              _stepController.clear();
            },
          ),
          BlocListener<FetchCustomFieldsCubit, FetchCustomFieldState>(
            listenWhen: (previous, current) =>
                current is FetchCustomFieldSuccess,
            listener: (context, state) {
              if (state is! FetchCustomFieldSuccess) return;
              final cubit = context.read<AdPostingCubit>();
              if (state.fields.isEmpty) {
                cubit.removeStep(AdPostingStep.customFields);
              } else {
                cubit.addStep(
                  AdPostingStep.customFields,
                  after: AdPostingStep.baseDetails,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<AdPostingCubit, AdPostingState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: context.color.backgroundColor,
              appBar: UiUtils.buildAppBar(
                context,
                showBackButton: true,
                title: 'adListing'.translate(context),
                onBackPress: () => _onBack(state),
              ),
              bottomNavigationBar: const AdPostingFormButtons(),
              body: Column(
                children: [
                  const AdPostingStepHeader(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.steps.length,
                      itemBuilder: (context, index) {
                        return _stepFor(state.steps[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
