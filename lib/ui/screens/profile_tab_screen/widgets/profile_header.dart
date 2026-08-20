import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/seller/fetch_verification_request_cubit.dart';
import 'package:eClassify/data/model/user/verification_request.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/follow_users_count_widget.dart';
import 'package:eClassify/ui/screens/widgets/auto_size_text.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/color_mappers/svg_color_mapper.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = HiveUtils.isUserAuthenticated();

    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 12,
          children: [
            _ProfileDetails(isAuthenticated: isAuthenticated),
            if (isAuthenticated) ...[
              const Divider(height: 1),
              FollowUsersCountWidget(),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    final user = HiveUtils.getUserDetails();
    final config = switch (isAuthenticated) {
      true => (title: user.name, subtitle: user.email),
      false => (
        title: 'guestUser'.translate(context),
        subtitle: 'loginFirst'.translate(context),
      ),
    };

    return Row(
      spacing: 10,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: context.colorScheme.surface,
          child: CustomImage(
            src: user.profile,
            size: Size.square(64),
            radius: 32,
            errorImage: CustomImage(
              src: AppAssets.profile.defaultPerson,
              svgColorMapper: SvgColorMapper(
                color: context.colorScheme.primary,
              ),
              radius: 32,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (config.title.isNotNullAndNotEmpty)
                Row(
                  spacing: 2,
                  children: [
                    Text(config.title!, style: context.labelLarge.bold),
                    if (HiveUtils.isUserAuthenticated()) const _VerifiedIcon(),
                  ],
                ),
              if (config.subtitle.isNotNullAndNotEmpty)
                Text(config.subtitle!, style: context.bodyMedium),
            ],
          ),
        ),
        if (!isAuthenticated)
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: Size(100, 40),
              maximumSize: Size(150, 40),
              padding: EdgeInsets.symmetric(horizontal: 8),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.login);
            },
            child: AutoSizeText(
              text: 'login'.translate(context),
              maxLines: 1,
              style: context.labelLarge,
              textAlign: TextAlign.center,
              minimumFontSize: 8,
            ),
          )
        else
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: context.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(
                Routes.completeProfile,
                arguments: {'from': 'profile'},
              );
            },
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(AppIcons.pencilSimpleLine),
            ),
          ),
      ],
    );
  }
}

class _VerifiedIcon extends StatelessWidget {
  const _VerifiedIcon();

  @override
  Widget build(BuildContext context) {
    final user = HiveUtils.getUserDetails();
    final isVerified = context.select<VerificationRequestCubit, bool>(
      (cubit) => switch (cubit.state) {
        final VerificationRequestSuccess s
            when s.request.status == VerificationRequestStatus.approved =>
          true,
        _ => user.isVerified ?? false,
      },
    );
    if (isVerified) {
      return Icon(
        AppIcons.sealCheckFill,
        size: 16,
        color: context.colorScheme.tertiary,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
