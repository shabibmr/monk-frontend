/// Stable IDs for offline demo deep links and seed graph.
/// Keep in sync with docs/frontend-tasks/demo-mock/TASKS.md.
abstract final class MockIds {
  // Users
  static const admin = 'user-demo-admin';
  static const brand1 = 'user-demo-brand1';
  static const creator1 = 'user-demo-creator1';
  static const manager1 = 'user-demo-manager1';
  static const agency1 = 'user-demo-agency1';
  static const brandFresh = 'user-demo-brand-fresh';
  static const creatorFresh = 'user-demo-creator-fresh';

  // Orgs / profiles
  static const brandOrg1 = 'brand-demo-1';
  static const brandOrg2 = 'brand-demo-2';
  static const influencer1 = 'inf-demo-1';
  static const influencer2 = 'inf-demo-2';
  static const influencer3 = 'inf-demo-3';

  // Marketplace spine
  static const campaign1 = 'camp-demo-1';
  static const campaign2 = 'camp-demo-2';
  static const campaign3 = 'camp-demo-3';
  static const campaignDraft = 'camp-demo-draft';
  static const campaignDone = 'camp-demo-done';
  static const application1 = 'app-demo-1';
  static const negotiation1 = 'neg-demo-1';
  static const collab1 = 'collab-demo-1';
  static const contract1 = 'contract-demo-1';
  static const content1 = 'content-demo-1';
  static const published1 = 'pub-demo-1';
  static const payment1 = 'pay-demo-1';
  static const shortlist1 = 'shortlist-demo-1';

  // Platform
  static const kyc1 = 'kyc-demo-1';
  static const chatThread1 = 'chat-demo-1';
  static const dispute1 = 'dispute-demo-1';
  static const referralReward1 = 'ref-reward-demo-1';
  static const brief1 = 'brief-demo-1';
  static const session1 = 'session-demo-1';

  static const demoPassword = '123456';

  /// Sign-in names for the offline demo. Deliberately short — the legacy
  /// `demo.*@influencersmonk.local` forms still resolve via
  /// `MockSeedStore.findAccountByEmail`.
  static const emailAdmin = 'admin';
  static const emailBrand1 = 'brand';
  static const emailCreator1 = 'creator';
  static const emailManager1 = 'manager';
  static const emailAgency1 = 'agency';
  static const emailBrandFresh = 'newbrand';
  static const emailCreatorFresh = 'newcreator';

  /// Display-only addresses (company contacts, dispute/referral labels).
  /// Never used for sign-in.
  static const contactEmailBrand1 = 'priya@brandco.demo';
  static const contactEmailBrandFinance = 'finance@brandco.demo';
  static const contactEmailCreator1 = 'arjun@creators.demo';
  static const contactEmailCreatorFresh = 'newcreator@creators.demo';
}
