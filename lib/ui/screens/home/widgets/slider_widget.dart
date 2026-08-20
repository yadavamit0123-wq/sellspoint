import 'dart:async';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/home/slider_cubit.dart';
import 'package:eClassify/data/model/home/home_slider.dart';
import 'package:eClassify/data/model/item/item_list.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  final _controller = PageController();
  Timer? _timer;
  int _totalPage = 0;

  @override
  void dispose() {
    _clearTimer();
    _controller.dispose();
    super.dispose();
  }

  void _clearTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    _clearTimer();
    if (_totalPage > 0) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) => _nextPage());
    }
  }

  void _nextPage() {
    final currentPage = _controller.page?.toInt() ?? 0;
    final nextPage = currentPage + 1;
    if (nextPage < _totalPage) {
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _controller.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SliderCubit, SliderState>(
      listener: (context, state) {
        if (state is SliderSuccess) {
          _totalPage = state.sliders.length;
          if (_totalPage > 1) {
            _startTimer();
          }
        }
      },
      builder: (context, state) {
        if (state is SliderLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: Constant.horizontalPadding,
            ),
            child: AspectRatio(aspectRatio: 2, child: const CustomShimmer()),
          );
        }
        if (state is SliderFailure) {
          return const SizedBox.shrink();
        }
        if (state is SliderSuccess) {
          if (state.sliders.isEmpty) {
            return const SizedBox.shrink();
          }

          final imageSize = context.sizeFromAspectRatio(2);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: AspectRatio(
              aspectRatio: 2,
              child: PageView.builder(
                controller: _controller,
                itemCount: state.sliders.length,
                itemBuilder: (context, index) {
                  final slider = state.sliders[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Constant.horizontalPadding,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _SliderTapHandler.handle(context, slider);
                      },
                      child: RepaintBoundary(
                        child: CustomImage(
                          src: slider.image,
                          fit: BoxFit.fill,
                          size: imageSize,
                          radius: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SliderTapHandler {
  static void handle(BuildContext context, HomeSlider slider) async {
    switch (slider) {
      case final CategorySlider s:
        _categorySliderHandler(context, s);
      case final ItemSlider s:
        _itemSliderHandler(context, s);
      case final ExternalLinkSlider s:
        _externalLinkHandler(context, s);
      default:
        throw UnsupportedError('Unsupported slider type');
    }
    ;
  }

  static void _categorySliderHandler(
    BuildContext context,
    CategorySlider slider,
  ) {
    final category = slider.category;
    if (category.hasSubCategories) {
      Navigator.of(
        context,
      ).pushNamed(Routes.categoryBrowsing, arguments: category);
    } else {
      Navigator.of(context).pushNamed(
        Routes.itemsList,
        arguments: CategoryMetaData(category: category),
      );
    }
  }

  static void _itemSliderHandler(BuildContext context, ItemSlider slider) {
    Navigator.of(
      context,
    ).pushNamed(Routes.adDetailsScreen, arguments: {'item_id': slider.itemId});
  }

  static void _externalLinkHandler(
    BuildContext context,
    ExternalLinkSlider slider,
  ) async {
    final canLaunch = await canLaunchUrl(slider.url);
    if (canLaunch) {
      launchUrl(slider.url);
    }
  }
}
