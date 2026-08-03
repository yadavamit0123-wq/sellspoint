// my_referral_widget.dart
import 'package:eClassify/data/cubits/referral/referral_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';

class MyReferralWidget extends StatefulWidget {
  const MyReferralWidget({super.key});

  @override
  State<MyReferralWidget> createState() => _MyReferralWidgetState();
}

class _MyReferralWidgetState extends State<MyReferralWidget> {
  String filter = 'All'; // Default filter

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReferralBloc()..fetchReferrals(),
      child: Column(
        children: [
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Referrals'.translate(context),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.color.textColorDark,
                  ),
                ),
              ],
            ),
          ),
          // Referral List
          Expanded(
            child: BlocBuilder<ReferralBloc, ReferralListState>(
              builder: (context, state) {
                if (state is ReferralListLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ReferralListSuccess) {
                  final referralUsers = state.referrals;

                  if (referralUsers.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No referrals found'.translate(context),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            color: context.color.textColorDark.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: referralUsers.length,
                    itemBuilder: (context, index) {
                      final referral = referralUsers[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: context.color.territoryColor.withValues(alpha: 0.2),
                            child: Text(
                                (referral.user?.name == null || (referral.user?.name?.isEmpty ?? true)) ? '-' : referral.user?.name?.split('')[0].toUpperCase() ?? 'n',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                                color: context.color.territoryColor,
                              ),
                            ),
                          ),
                          title: Text(
                            referral.user?.name ?? '----',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              // Text(
                              //   referral.user?.mobile ?? '----',
                              //   style: TextStyle(
                              //     fontFamily: 'Manrope',
                              //     fontSize: 14,
                              //     color: context.color.textColorDark.withValues(alpha: 0.7),
                              //   ),
                              // ),
                              Text(
                                'Date: ${referral.createdAt?.split('T')[0]}',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  color: context.color.textColorDark.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          // trailing: Column(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     _buildStatusBadge(
                          //       context,
                          //       referral.installed ? 'Installed' : 'Not Installed',
                          //       referral.installed ? Colors.green : Colors.red,
                          //     ),
                          //     const SizedBox(height: 4),
                          //     _buildStatusBadge(
                          //       context,
                          //       referral.rewarded ? 'Rewarded' : 'Not Rewarded',
                          //       referral.rewarded ? Colors.green : Colors.red,
                          //     ),
                          //   ],
                          // ),
                        ),
                      );
                    },
                  );
                } else if (state is ReferralListError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load referrals: ${state.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ReferralBloc>().fetchReferrals();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            text.toLowerCase().contains('installed') || text.toLowerCase().contains('rewarded')
                ? Icons.check_circle
                : Icons.cancel,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}