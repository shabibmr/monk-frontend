import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monk_web/core/session/session_cubit.dart';
import 'package:monk_web/core/session/token_store.dart';

void main() {
  test('setActiveProfile sets manager context fields', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final session = SessionCubit(TokenStore(prefs));

    session.setActiveProfile(
      profileId: 'prof-1',
      isManagerContext: true,
      displayName: 'Asha',
      permissions: const ['view_earnings'],
    );

    expect(session.state.activeProfileId, 'prof-1');
    expect(session.state.isManagerContext, isTrue);
    expect(session.state.activeProfileName, 'Asha');
    expect(session.state.managerPermissions, ['view_earnings']);

    session.setActiveProfile(profileId: null, isManagerContext: false);
    expect(session.state.activeProfileId, isNull);
    expect(session.state.isManagerContext, isFalse);
    expect(session.state.managerPermissions, isEmpty);
  });
}
