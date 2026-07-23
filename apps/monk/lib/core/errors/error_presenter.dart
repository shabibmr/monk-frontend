import 'package:flutter/material.dart';
import 'package:monk_shared/monk_shared.dart';

import '../widgets/im_toast.dart';
import 'failures.dart';

abstract final class ErrorPresenter {
  static void show(BuildContext context, Failure failure) {
    final isRateLimited = failure.errorCode == ErrorCode.rateLimited ||
        failure.message.toLowerCase().contains('too many');
    final tone = isRateLimited
        ? ImToastTone.warning
        : switch (failure) {
            AuthFailure() => ImToastTone.danger,
            ValidationFailure() => ImToastTone.warning,
            ForbiddenFailure() => ImToastTone.warning,
            NetworkFailure() => ImToastTone.warning,
            ServerFailure() => ImToastTone.danger,
            _ => ImToastTone.danger,
          };
    final message = isRateLimited
        ? 'Rate limited — please wait and try again.'
        : failure.message;
    ImToast.show(context, message: message, tone: tone);
  }
}
