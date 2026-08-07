import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/video_ad_editor_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdPostingAdTypeStep extends StatefulWidget {
  const AdPostingAdTypeStep({super.key});

  @override
  State<AdPostingAdTypeStep> createState() => _AdPostingAdTypeStepState();
}

class _AdPostingAdTypeStepState extends State<AdPostingAdTypeStep> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cubit = context.read<AdPostingCubit>();
    final selected = cubit.state.adPostingData.adType != null;
    AdPostingStepController.of(context).register(
      onNext: selected
          ? () => _onContinue(context)
          : null,
      showNext: selected,
    );
  }

  void _onContinue(BuildContext context) {
    final cubit = context.read<AdPostingCubit>();
    final type = cubit.state.adPostingData.adType;
    if (type == AdItemType.videoAd &&
        AppConfig.enableAdPostingVideoAdTypeV214) {
      VideoAdEditorLauncher.openFromAdPostingWizard(context);
      return;
    }
    cubit.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdPostingCubit, AdPostingState>(
      builder: (context, state) {
        final cubit = context.read<AdPostingCubit>();
        final selected = state.adPostingData.adType;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TypeCard(
                title: 'adListing'.translate(context),
                subtitle: 'postAdSubtitle'.translate(context),
                icon: Icons.storefront_outlined,
                isSelected: selected == AdItemType.regularAd,
                onTap: () {
                  cubit.updateData(
                    (d) => d.copyWith(adType: AdItemType.regularAd),
                  );
                  AdPostingStepController.of(context).register(
                    onNext: () => _onContinue(context),
                    showNext: true,
                  );
                },
              ),
              const SizedBox(height: 16),
              _TypeCard(
                title: 'videoAds'.translate(context),
                subtitle: 'postAdSubtitle'.translate(context),
                icon: Icons.play_circle_outline,
                isSelected: selected == AdItemType.videoAd,
                enabled: AppConfig.enableAdPostingVideoAdTypeV214,
                onTap: () {
                  if (!AppConfig.enableAdPostingVideoAdTypeV214) return;
                  cubit.updateData(
                    (d) => d.copyWith(adType: AdItemType.videoAd),
                  );
                  AdPostingStepController.of(context).register(
                    onNext: () => _onContinue(context),
                    showNext: true,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: isSelected
            ? context.color.territoryColor.withValues(alpha: 0.08)
            : context.color.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? context.color.territoryColor
                    : context.color.borderColor.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      context.color.territoryColor.withValues(alpha: 0.12),
                  child: Icon(icon, color: context.color.territoryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        title,
                        fontWeight: FontWeight.w600,
                        color: context.color.textDefaultColor,
                      ),
                      CustomText(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        fontSize: context.font.small,
                        color: context.color.textLightColor,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: context.color.territoryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
