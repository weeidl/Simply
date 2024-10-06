import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_segmented_control_state.dart';

class AuthSegmentedControlCubit extends Cubit<AuthSegmentedControlState> {
  AuthSegmentedControlCubit() : super(AuthSegmentedControlState.login);

  void showLogin() => emit(AuthSegmentedControlState.login);

  void showRegister() => emit(AuthSegmentedControlState.register);

  void setSegmentedControlState(AuthSegmentedControlState newValue) {
    emit(newValue);
  }
}
