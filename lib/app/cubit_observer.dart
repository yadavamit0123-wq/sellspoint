import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppCubitObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    Log.debug('[${bloc.runtimeType.toString()}] $change');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    Log.debug('[${bloc.runtimeType.toString()}] $transition');
  }
}
