import 'package:eClassify/data/cubits/item/delete_item_cubit.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemListeners extends StatelessWidget {
  const ItemListeners({
    required this.child,
    required this.onComplete,
    super.key,
  });

  final Widget child;
  final ValueChanged<bool> onComplete;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DeleteItemCubit, DeleteItemState>(
          listener: (context, state) {
            if (state is DeleteItemInProgress) {
              LoadingOverlay.show(context);
            }
            if (state is DeleteItemSuccess) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(
                context,
                "deletedSuccessfully".translate(context),
                type: MessageType.success,
              );
              onComplete(true);
            }
            if (state is DeleteItemFailure) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(
                context,
                state.errorMessage,
                type: MessageType.error,
              );
              onComplete(false);
            }
          },
        ),
      ],
      child: child,
    );
  }
}
