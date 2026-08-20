// referral_program_screen.dart
import 'dart:io';
import 'package:eClassify/data/cubits/referral/referral_cubit.dart';
import 'package:eClassify/data/model/faq_response.dart';
import 'package:eClassify/data/model/user_model.dart';
import 'package:eClassify/ui/screens/referral_program/widgets/my_referral_widget.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Referral Program Screen
class ReferralProgramScreen extends StatefulWidget {
  const ReferralProgramScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) => const ReferralProgramScreen(),
    );
  }

  @override
  State<ReferralProgramScreen> createState() => _ReferralProgramScreenState();
}

class _ReferralProgramScreenState extends State<ReferralProgramScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? referralCode;
  String filter = 'All'; // Default filter
  UserModel? userData;

  @override
  void initState() {
    super.initState();
    getMyReferCode();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void getMyReferCode(){
    var myData = HiveUtils.getUserDetails();
    userData = myData;
    referralCode = userData?.referId ?? userData?.referralCode ?? 'null';
  }

  void shareApp() {
    try {
      if (Platform.isAndroid) {
          // '${Constant.shareappText}$referralCode${Constant.shareappTextSecond}\n${Constant.playstoreURLAndroid}',
        Share.share(
          '${Constant.shareappText}$referralCode${Constant.shareappTextSecond}\n${Constant.inviteURL}',
          subject: Constant.appName,
        );
      } else {
        Share.share(
          '${Constant.shareappText}$referralCode${Constant.shareappTextSecond}\n${Constant.inviteURL}',
          subject: Constant.appName,
          sharePositionOrigin: Rect.fromLTWH(
            0,
            0,
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height / 2,
          ),
        );
      }
    } catch (e) {
      HelperUtils.showSnackBarMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context, statusBarColor: context.color.secondaryColor),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(
          showBackButton: true,
          context,
          title: "Referral Program".translate(context),
        ),
        body: ScrollConfiguration(
          behavior: RemoveGlow(),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Refer'),
                  Tab(text: 'My Referrals'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Refer Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/gift.svg',
                            height: size.height * 0.3,
                            width: size.width,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Earn ₹10 \nBy Inviting Your Friends & Family',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Invite friends to Sell Point and get ₹10 when your friend registers with phone number. They get ₹5!',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(referralCode?.toString() ?? ''),
                                      const SizedBox(width: 15),
                                      InkWell(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: referralCode ?? 'null'));
                                          HelperUtils.showSnackBarMessage(context, 'Referral code copied!');
                                        },
                                        child: const Icon(Icons.copy, size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 50),
                              InkWell(
                                onTap: () async {
                                  var shareText = '';
                                  if (Platform.isAndroid) {
                                    shareText = '${Constant.shareappText}$referralCode${Constant.shareappTextSecond}\n${Constant.inviteURL}';
                                  } else {
                                    shareText = '${Constant.shareappText}$referralCode${Constant.shareappTextSecond}\n${Constant.inviteURL}';
                                  }
                                  final whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(shareText)}';
                                  if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                                    await launchUrl(Uri.parse(whatsappUrl));
                                  } else {
                                    HelperUtils.showSnackBarMessage(context, 'WhatsApp is not installed');
                                  }
                                },
                                child: Image.asset(
                                  'assets/svg/whatsapp.png',
                                  width: 35,
                                  height: 35,
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () => shareApp(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              'Questions & Answers',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          BlocProvider(
                            create: (_) => ReferralCubit()..fetchReferralFaqs(),
                            child: BlocBuilder<ReferralCubit, ReferralState>(
                              builder: (context, state) {
                                if (state is ReferralLoading) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (state is ReferralSuccess) {
                                  if (state.faqs.isEmpty) {
                                    return const Center(child: Text('No FAQs available'));
                                  }
                                  return ListView(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: state.faqs.map((faq) => ExpansionTile(
                                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                      expandedAlignment: Alignment.centerLeft,
                                      tilePadding: EdgeInsets.zero,
                                      title: Text(faq.quetions, style: TextStyle(fontWeight: FontWeight.w900),),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                                          child: Text(
                                            faq.answers,
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ],
                                    )).toList(),
                                  );
                                } else if (state is ReferralError) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Failed to load FAQs: ${state.errorMessage}',
                                          style: const TextStyle(color: Colors.red),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            context.read<ReferralCubit>().fetchReferralFaqs();
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
                    ),
                    // My Referrals Tab
                    const MyReferralWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}