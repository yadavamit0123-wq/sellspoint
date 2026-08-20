import 'package:flutter/material.dart';

class AdPostingStepController extends ChangeNotifier {
  VoidCallback? _onNext;
  VoidCallback? _onPrevious;
  VoidCallback? _onSubmit;
  bool _showNext = false;

  VoidCallback? get onNext => _onNext;
  VoidCallback? get onPrevious => _onPrevious;
  VoidCallback? get onSubmit => _onSubmit;
  bool get showNext => _showNext;

  void register({
    VoidCallback? onNext,
    VoidCallback? onPrevious,
    VoidCallback? onSubmit,
    bool showNext = false,
  }) {
    _onNext = onNext;
    _onPrevious = onPrevious;
    _onSubmit = onSubmit;
    _showNext = showNext || onNext != null;

    // Defer notification to avoid setState/markNeedsBuild warnings during build/didChangeDependencies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void clear() {
    _onNext = null;
    _onPrevious = null;
    _onSubmit = null;
    _showNext = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  static AdPostingStepController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AdPostingStepControllerProvider>();
    assert(provider != null, 'No AdPostingStepControllerProvider found in context');
    return provider!.controller;
  }
}

class AdPostingStepControllerProvider extends InheritedWidget {
  final AdPostingStepController controller;

  const AdPostingStepControllerProvider({
    required this.controller,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(AdPostingStepControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
