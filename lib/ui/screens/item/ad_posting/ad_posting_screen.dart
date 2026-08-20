import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/ai/generate_description_cubit.dart';
import 'package:eClassify/data/cubits/ai/generate_meta_cubit.dart';
import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/data/cubits/custom_field/custom_fields_cubit.dart';
import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/data/cubits/item/manage_item_cubit.dart';
import 'package:eClassify/data/cubits/location/location_search_cubit.dart';
import 'package:eClassify/data/model/item/ad_posting_data.dart';
import 'package:eClassify/data/model/item/ad_posting_step.dart';
import 'package:eClassify/data/repositories/ai_repository.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_form_buttons.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_widget.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_type_selection/ad_type_selection_step.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/basic_details_form/basic_details_form.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/category_selection/category_breadcrumbs_view.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/category_selection/category_selection_step.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/custom_fields_form/custom_fields_form.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/location_selection_step/location_selection_step.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/media_selection/media_selection_step.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdPostingScreen extends StatefulWidget {
  const AdPostingScreen({this.data, super.key});

  final AdPostingData? data;

  static Route route(RouteSettings settings) {
    final data = settings.arguments as AdPostingData?;
    return MaterialPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AdPostingCubit(data)),
          BlocProvider(
            create: (_) => CategoryBrowsingCubit(showLastCategory: true),
          ),
          BlocProvider(create: (_) => CustomFieldsCubit()),
          BlocProvider(create: (_) => GenerateMetaCubit()),
          BlocProvider(
            create: (_) => GenerateDescriptionCubit(AIRepository.instance),
          ),
          if (Constant.systemSettings.mapProvider != 'free_api')
            BlocProvider(create: (_) => LocationSearchCubit()),
          BlocProvider(create: (_) => ManageItemCubit()),
        ],

        child: AdPostingScreen(data: data),
      ),
    );
  }

  @override
  State<AdPostingScreen> createState() => _AdPostingScreenState();
}

class _AdPostingScreenState extends State<AdPostingScreen> {
  final PageController _pageController = PageController();
  final AdPostingStepController _stepController = AdPostingStepController();

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      context.read<CustomFieldsCubit>().getCustomFields(
        categoryId: widget.data!.category!.id,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AdPostingCubit, AdPostingState>(
          listenWhen: (previous, current) =>
              previous.activeStep != current.activeStep,
          listener: (context, state) {
            final index = state.steps.indexOf(state.activeStep);
            if (_pageController.hasClients &&
                _pageController.page?.round() != index) {
              _pageController.jumpToPage(index);
            }
            _stepController.clear();
          },
        ),
        BlocListener<CustomFieldsCubit, CustomFieldsState>(
          listener: (context, state) {
            if (state case final CustomFieldsSuccess s
                when s.fields.isNotEmpty) {
              context.read<AdPostingCubit>().addStep(
                AdPostingStep.customFields,
                after: AdPostingStep.baseDetails,
              );
            }
          },
        ),
        BlocListener<ManageItemCubit, ManageItemState>(
          listener: (context, state) {
            if (state is ManageItemLoading) {
              LoadingOverlay.show(context);
            }
            if (state is ManageItemSuccess) {
              LoadingOverlay.hide();
              final isEdit = widget.data != null;
              Navigator.of(context).pushNamed(
                Routes.adPostingSuccessScreen,
                arguments: {
                  'item': state.item,
                  'isEdited': isEdit,
                  'isUploadInProgress': state.isUploadInProgress,
                },
              );
            }
            if (state is ManageItemFailure) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(context, state.message);
            }
          },
        ),
      ],
      child: AdPostingStepControllerProvider(
        controller: _stepController,
        child: BlocBuilder<AdPostingCubit, AdPostingState>(
          builder: (context, state) {
            final totalSteps = state.steps.length;
            return Scaffold(
              //resizeToAvoidBottomInset: false,
              appBar: AppBar(title: Text('adDetails'.translate(context))),
              bottomNavigationBar: const AdPostingFormButtons(),
              body: Column(
                children: [
                  AdPostingStepWidget(),
                  CategoryBreadcrumbsView(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalSteps,
                      itemBuilder: (context, index) {
                        final step = state.steps[index];
                        return _AdPostingStepFactory.getStep(step);
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

class _AdPostingStepFactory {
  static Widget getStep(AdPostingStep step) {
    return switch (step) {
      AdPostingStep.adType => const AdTypeSelectionStep(),
      AdPostingStep.category => const CategorySelectionStep(),
      AdPostingStep.baseDetails => const BasicDetailsForm(),
      AdPostingStep.customFields => const CustomFieldsForm(),
      AdPostingStep.mediaUpload => const MediaSelectionStep(),
      AdPostingStep.location => const LocationSelectionStep(),
    };
  }
}
