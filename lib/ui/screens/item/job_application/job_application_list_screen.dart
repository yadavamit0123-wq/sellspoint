import 'package:eClassify/data/cubits/item/job_application/change_job_application_status_cubit.dart';
import 'package:eClassify/data/cubits/item/job_application/fetch_job_application_cubit.dart';
import 'package:eClassify/data/model/item/job_application.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class JobApplicationListScreen extends StatefulWidget {
  const JobApplicationListScreen({
    super.key,
    required this.itemId,
    this.isRecruiterView = true,
  });

  final int itemId;
  final bool isRecruiterView;

  static Route route(RouteSettings settings) {
    final args = settings.arguments as Map? ?? {};
    return BlurredRouter(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ChangeJobApplicationStatusCubit()),
        ],
        child: JobApplicationListScreen(
          itemId: args['itemId'] as int? ?? 0,
          isRecruiterView: args['isRecruiterView'] as bool? ?? true,
        ),
      ),
    );
  }

  @override
  State<JobApplicationListScreen> createState() =>
      _JobApplicationListScreenState();
}

class _JobApplicationListScreenState extends State<JobApplicationListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (HiveUtils.isUserAuthenticated()) {
      context.read<FetchJobApplicationCubit>().fetchApplications(
            itemId: widget.itemId,
            isMyJobApplications: !widget.isRecruiterView,
          );
    }
    _scrollController.addListener(() {
      if (!_scrollController.isEndReached()) return;
      if (context.read<FetchJobApplicationCubit>().hasMoreData()) {
        context.read<FetchJobApplicationCubit>().fetchMore(
              itemId: widget.itemId,
              isMyJobApplications: !widget.isRecruiterView,
            );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChangeJobApplicationStatusCubit,
        ChangeJobApplicationStatusState>(
      listener: (context, state) {
        if (state is ChangeJobApplicationStatusSuccess) {
          HelperUtils.showSnackBarMessage(context, state.message);
          context.read<FetchJobApplicationCubit>().fetchApplications(
                itemId: widget.itemId,
                isMyJobApplications: !widget.isRecruiterView,
              );
        }
      },
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: 'jobApplications'.translate(context),
        ),
        body: BlocBuilder<FetchJobApplicationCubit, FetchJobApplicationState>(
          builder: (context, state) {
            if (state is FetchJobApplicationInProgress ||
                state is FetchJobApplicationInitial) {
              return UiUtils.progress();
            }
            if (state is FetchJobApplicationFailed) {
              return Center(child: CustomText(state.error.toString()));
            }
            if (state is FetchJobApplicationSuccess) {
              if (state.applications.isEmpty) {
                return NoDataFound(onTap: () {});
              }
              return ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.applications.length +
                    (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= state.applications.length) {
                    return UiUtils.progress();
                  }
                  return _ApplicationCard(
                    app: state.applications[index],
                    showActions: widget.isRecruiterView,
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.app,
    required this.showActions,
  });

  final JobApplication app;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.color.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            app.fullName ?? '',
            fontWeight: FontWeight.w700,
            fontSize: context.font.large,
          ),
          if (app.email != null && app.email!.isNotEmpty)
            CustomText(app.email!, fontSize: context.font.small),
          if (app.mobile != null && app.mobile!.isNotEmpty)
            CustomText(
              '${'mobileNumberLbl'.translate(context)}: ${app.mobile}',
              fontSize: context.font.small,
            ),
          if (app.resume != null && app.resume!.isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _openResume(app.resume!),
              child: CustomText(
                'uploadFile'.translate(context),
                color: context.color.territoryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (showActions && app.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _setStatus(context, app.id, 'accepted'),
                    child: Text('accept'.translate(context)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _setStatus(context, app.id, 'rejected'),
                    child: Text('reject'.translate(context)),
                  ),
                ),
              ],
            )
          else if (app.status != null)
            CustomText(
              app.status!.translate(context),
              fontWeight: FontWeight.w600,
              color: app.status == 'accepted' ? Colors.green : Colors.red,
            ),
        ],
      ),
    );
  }

  void _setStatus(BuildContext context, int id, String status) {
    context.read<ChangeJobApplicationStatusCubit>().changeJobApplicationStatus(
          id: id,
          status: status,
        );
  }

  Future<void> _openResume(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
