import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ep.dart';
import 'package:toastification/toastification.dart';

void connectionToast(BuildContext context, String title, String description,
    {bool isConnected = true}) {
  toastification.dismissAll();

  toastification.show(
    context: context,
    type: ToastificationType.success,
    style: ToastificationStyle.flat,
    autoCloseDuration: const Duration(seconds: 3),
    alignment: Alignment.bottomCenter,
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    description: Text(
      description,
      style: TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
    ),
    icon: Icon(
      isConnected ? Icons.wifi : Icons.wifi_off,
      color: Colors.black,
    ),
    animationDuration: const Duration(milliseconds: 300),
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    showIcon: true,
    primaryColor: Colors.black,
    backgroundColor: Color.fromARGB(255, 255, 255, 255),
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
    closeOnClick: true,
    pauseOnHover: true,
    dragToClose: true,
    callbacks: ToastificationCallbacks(
      onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
      onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
    ),
  );
}

void bluetoothToast(BuildContext context, String title, String description,
    {bool isConnected = true}) {
  toastification.dismissAll();

  toastification.show(
    context: context,
    type: ToastificationType.success,
    style: ToastificationStyle.flat,
    autoCloseDuration: const Duration(seconds: 3),
    alignment: Alignment.bottomCenter,
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    description: Text(
      description,
      style: TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
    ),
    icon: Icon(
      isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
      color: Colors.black,
    ),
    animationDuration: const Duration(milliseconds: 300),
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    showIcon: true,
    primaryColor: Colors.black,
    backgroundColor: Color.fromARGB(255, 255, 255, 255),
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
    closeOnClick: true,
    pauseOnHover: true,
    dragToClose: true,
    callbacks: ToastificationCallbacks(
      onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
      onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
    ),
  );
}

void successToast(BuildContext context, String title, String text) {
  toastification.show(
    context: context, // optional if you use ToastificationWrapper
    type: ToastificationType.success,
    style: ToastificationStyle.flat,
    autoCloseDuration: const Duration(seconds: 2),
    alignment: Alignment.topCenter,

    title: Text('Pemberitahuan!'),
    // you can also use RichText widget for title and description parameters
    description: RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.black),
      ),
    ),
    direction: TextDirection.ltr,
    animationDuration: const Duration(milliseconds: 300),
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    icon: const Icon(Icons.check),
    showIcon: true, // show or hide the icon
    primaryColor: Colors.green,
    backgroundColor: Colors.green,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
    showProgressBar: true,
    closeButtonShowType: CloseButtonShowType.onHover,
    closeOnClick: true,
    pauseOnHover: true,
    dragToClose: true,
    applyBlurEffect: true,
    callbacks: ToastificationCallbacks(
      onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
      onCloseButtonTap: (toastItem) =>
          print('Toast ${toastItem.id} close button tapped'),
      onAutoCompleteCompleted: (toastItem) =>
          print('Toast ${toastItem.id} auto complete completed'),
      onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
    ),
  );
}

void failedToast(BuildContext context, String title, String text) {
  toastification.dismissAll();

  toastification.show(
    context: context, // optional if you use ToastificationWrapper
    type: ToastificationType.warning,

    style: ToastificationStyle.fillColored,
    autoCloseDuration: const Duration(seconds: 10),

    title: Text('Pemberitahuan!'),
    // you can also use RichText widget for title and description parameters
    description: RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.white),
      ),
    ),
    alignment: Alignment.topCenter,
    direction: TextDirection.ltr,
    animationDuration: const Duration(milliseconds: 300),
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    icon: const Icon(Icons.error),
    showIcon: true, // show or hide the icon
    primaryColor: Colors.red,
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
    progressBarTheme: ProgressIndicatorThemeData(
      color: Colors.white,
      linearTrackColor: const Color.fromARGB(255, 156, 45, 37),
    ),
    showProgressBar: true,
    closeButtonShowType: CloseButtonShowType.always,

    closeOnClick: true,
    pauseOnHover: true,
    dragToClose: true,
    callbacks: ToastificationCallbacks(
      onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
      onCloseButtonTap: (toastItem) =>
          print('Toast ${toastItem.id} close button tapped'),
      onAutoCompleteCompleted: (toastItem) =>
          print('Toast ${toastItem.id} auto complete completed'),
      onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
    ),
  );
}

void successToastFilledColor(BuildContext context, String title, String text) {
  toastification.dismissAll();

  toastification.show(
    context: context, // optional if you use ToastificationWrapper
    type: ToastificationType.success,

    style: ToastificationStyle.fillColored,
    autoCloseDuration: const Duration(seconds: 10),

    title: Text('Pemberitahuan!'),
    // you can also use RichText widget for title and description parameters
    description: RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.white),
      ),
    ),
    alignment: Alignment.topRight,
    direction: TextDirection.ltr,
    animationDuration: const Duration(milliseconds: 300),
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    icon: const Iconify(
      Ep.success_filled,
      color: Colors.white,
    ),
    showIcon: true, // show or hide the icon
    primaryColor: Colors.green,
    backgroundColor: Colors.white,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
    // progressBarTheme: ProgressIndicatorThemeData(
    //   color: Colors.white,
    //   linearTrackColor: const Color.fromARGB(255, 156, 45, 37),
    // ),
    // showProgressBar: true,
    closeButtonShowType: CloseButtonShowType.always,

    closeOnClick: true,
    pauseOnHover: true,
    dragToClose: true,
    callbacks: ToastificationCallbacks(
      onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
      onCloseButtonTap: (toastItem) =>
          print('Toast ${toastItem.id} close button tapped'),
      onAutoCompleteCompleted: (toastItem) =>
          print('Toast ${toastItem.id} auto complete completed'),
      onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
    ),
  );
}
