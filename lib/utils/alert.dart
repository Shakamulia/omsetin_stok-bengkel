import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

void showStatusDialog(BuildContext context, String message) {
  Future.delayed(const Duration(milliseconds: 500), () {
    QuickAlert.show(
      context: context,
      animType: QuickAlertAnimType.scale,
      type: QuickAlertType.success,
      title: 'Sukses!',
      text: message,
      confirmBtnText: 'OK',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
    );
  });
}

void showErrorDialog(BuildContext context, String message) {
  Future.delayed(const Duration(milliseconds: 500), () {
    QuickAlert.show(
      context: context,
      animType: QuickAlertAnimType.scale,
      type: QuickAlertType.error,
      title: 'Error!',
      text: message,
      confirmBtnText: 'OK',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
    );
  });
}

void showWarningDialog(BuildContext context, String message) {
  Future.delayed(const Duration(milliseconds: 500), () {
    QuickAlert.show(
      context: context,
      animType: QuickAlertAnimType.scale,
      type: QuickAlertType.warning,
      title: 'Warning!',
      text: message,
      confirmBtnText: 'OK',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
    );
  });
}

void showInfoDialog(BuildContext context, String message) {
  Future.delayed(const Duration(milliseconds: 500), () {
    QuickAlert.show(
      context: context,
      animType: QuickAlertAnimType.scale,
      type: QuickAlertType.info,
      title: 'Info',
      text: message,
      confirmBtnText: 'OK',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
    );
  });
}
