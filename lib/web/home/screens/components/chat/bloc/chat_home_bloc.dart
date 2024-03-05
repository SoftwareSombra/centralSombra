import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../chat/services/chat_services.dart';
import 'chat_home_event.dart';
import 'chat_home_state.dart';

class ChatHomeBloc extends Bloc<ChatHomeEvent, ChatHomeState> {
  final ChatServices chatServices = ChatServices();
  StreamSubscription? _chatSubscription;

  ChatHomeBloc() : super(ChatHomeInitial()) {
    on<LoadChatHomeEvent>((event, emit) async {
      emit(ChatHomeLoading());
      _chatSubscription?.cancel();
      _chatSubscription = chatServices.getUsersConversations().listen(
        (event) {
          if (event.docs.isEmpty) {
            emit(ChatHomeEmpty());
          } else {
            QuerySnapshot<Map<String, dynamic>> snapshot = event;
            snapshot.docs.map((DocumentSnapshot document) {
              String uid = document.id;
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              int unreadCount = data['unreadCount'] ?? 0;
              emit(ChatHomeLoaded(unreadCount, uid));
            }).toList();
          }
        },
        onError: (e) {
          emit(ChatHomeError(e.toString()));
        },
      );
    });
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    return super.close();
  }
}
