import 'package:monk_shared/monk_shared.dart';

import '../mock_ids.dart';
import '../mock_seed_store.dart';

void seedDemoAccounts(MockSeedStore store) {
  const pwd = MockIds.demoPassword;

  store.registerAccount(
    DemoAccount(
      user: MockSeedStore.makeUser(
        id: MockIds.admin,
        email: MockIds.emailAdmin,
        role: UserRole.admin,
        fullName: 'Demo Admin',
      ),
      password: pwd,
    ),
  );

  store.registerAccount(
    DemoAccount(
      user: MockSeedStore.makeUser(
        id: MockIds.brand1,
        email: MockIds.emailBrand1,
        role: UserRole.brandUser,
        fullName: 'Priya Brand',
      ),
      password: pwd,
      brandId: MockIds.brandOrg1,
      brandOnboardingComplete: true,
    ),
  );

  store.registerAccount(
    DemoAccount(
      user: MockSeedStore.makeUser(
        id: MockIds.creator1,
        email: MockIds.emailCreator1,
        role: UserRole.influencer,
        fullName: 'Arjun Creator',
      ),
      password: pwd,
      profileId: MockIds.influencer1,
      profileName: 'Arjun Creates',
      influencerOnboardingComplete: false,
    ),
  );

  store.registerAccount(
    DemoAccount(
      user: MockSeedStore.makeUser(
        id: MockIds.manager1,
        email: MockIds.emailManager1,
        role: UserRole.manager,
        fullName: 'Meera Manager',
      ),
      password: pwd,
      profileId: MockIds.influencer1,
      profileName: 'Arjun Creates',
      isManagerContext: true,
      managerPermissions: const [
        'view_earnings',
        'manage_applications',
        'manage_content',
      ],
    ),
  );

  store.registerAccount(
    DemoAccount(
      user: MockSeedStore.makeUser(
        id: MockIds.agency1,
        email: MockIds.emailAgency1,
        role: UserRole.agencyOperator,
        fullName: 'Alex Agency',
      ),
      password: pwd,
    ),
  );

  // Incomplete onboarding personas
  store.registerAccount(
    DemoAccount(
      user: MockSeedStore.makeUser(
        id: MockIds.brandFresh,
        email: MockIds.emailBrandFresh,
        role: UserRole.brandUser,
        fullName: 'Fresh Brand',
      ),
      password: pwd,
      brandOnboardingComplete: false,
    ),
  );

  store.registerAccount(
    DemoAccount(
      user: MockSeedStore.makeUser(
        id: MockIds.creatorFresh,
        email: MockIds.emailCreatorFresh,
        role: UserRole.influencer,
        fullName: 'Fresh Creator',
      ),
      password: pwd,
      influencerOnboardingComplete: false,
    ),
  );
}
