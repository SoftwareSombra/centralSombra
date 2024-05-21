import 'dart:io';
import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/swipebutton_services.dart';
import 'swipe_button_event.dart';
import 'swipe_button_state.dart';

class SwipeButtonBloc extends Bloc<SwipeButtonEvent, SwipeButtonState> {
  SwipeButtonBloc() : super(SwipeButtonInitial()) {
    SwipeButtonServices services = SwipeButtonServices();
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;

    on<SwipeButtonEvent>((event, emit) {});
    on<SwipeButtonLoad>(
      (event, emit) async {
        emit(SwipeButtonLoadind());
        try {
          bool status = await services.getStatus(uid);
          emit(SwipeButtonLoaded(status));
        } catch (e) {
          emit(SwipeButtonError(e.toString()));
        }
      },
    );
    on<SwipeButtonChange>(
      (event, emit) async {
        bool isTraking = await BackgroundLocationTrackerManager.isTracking();
        final bool isTraking2;
        debugPrint('---- isTraking: $isTraking ----');
        emit(SwipeButtonLoadind());
        try {
          if (event.isSwitched) {
            if (Platform.isIOS && !isTraking) {
              BackgroundLocationTrackerManager.startTracking();
            }
            if (Platform.isAndroid && !isTraking) {
              debugPrint('---- Android ----');
              BackgroundLocationTrackerManager.startTracking(
                config: const AndroidConfig(
                  notificationIcon: 'explore',
                  trackingInterval: Duration(minutes: 2),
                  distanceFilterMeters: 25,
                ),
              );
              debugPrint('-- Bg started --');
            }
          } else if (isTraking) {
            debugPrint('-- Bg stopped --');
            await BackgroundLocationTrackerManager.stopTracking();
            isTraking2 = await BackgroundLocationTrackerManager.isTracking();
            debugPrint('---- isTraking 2: $isTraking2 ----');
          }
          final bool isTraking3 = await BackgroundLocationTrackerManager.isTracking();
          debugPrint('---- isTraking 3: $isTraking3 ----');
          await services.changeStatus(event.isSwitched, uid);
          emit(SwipeButtonLoaded(event.isSwitched));
        } catch (e) {
          debugPrint('---- Error no SB: $e ----');
          emit(SwipeButtonError(e.toString()));
        }
      },
    );
  }
}
