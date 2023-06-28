import 'package:flutter/material.dart';

Future<T?> showTopModalDialog<T>(BuildContext context, Widget child,
    {bool barrierDismissible = true}) {
  return showGeneralDialog<T?>(
    context: context,
    barrierDismissible: barrierDismissible,
    transitionDuration: const Duration(milliseconds: 250),
    barrierLabel: MaterialLocalizations.of(context).dialogLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    pageBuilder: (context, _, __) => child,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)
            .drive(
                Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero)),
        child: Container(
          margin: const EdgeInsets.only(top: 80.0),
          child: Column(
            children: [
              Positioned(
                top: 80.0,
                child: Material(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [child],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
