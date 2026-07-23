import '../../../features/contracts/domain/entities/contract.dart';
import '../../../features/contracts/domain/entities/contract_amendment.dart';
import '../../../features/contracts/domain/entities/contract_template.dart';
import '../../../features/contracts/domain/repositories/contract_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// In-memory [ContractRepository].
///
/// Store keys:
/// - `contracts` → `List<Contract>`
/// - `contract_templates` → `List<ContractTemplate>`
/// - `contract_amendments` → `List<ContractAmendment>`
class MockContractRepository implements ContractRepository {
  MockContractRepository(this._store);

  final MockSeedStore _store;

  void _ensureFixtures() {
    if (_store.list<Contract>('contracts').isEmpty) {
      _store.putAll('contracts', [
        Contract(
          id: MockIds.contract1,
          collaborationId: MockIds.collab1,
          status: 'generated',
          contentHash: 'sha256-demo-contract-1',
          templateKey: 'standard_paid_v1',
          templateVersion: '1.0',
          pdfUrl: null,
          usageRights: const UsageRights(
            organicReuse: true,
            paidAmplification: false,
            durationDays: 90,
            territory: 'IN',
            channels: ['instagram', 'youtube'],
          ),
          acceptances: const [],
          bothPartiesAccepted: false,
        ),
      ]);
    }

    if (_store.list<ContractTemplate>('contract_templates').isEmpty) {
      _store.putAll('contract_templates', [
        ContractTemplate(
          id: 'tmpl-demo-1',
          key: 'standard_paid_v1',
          name: 'Standard Paid Collaboration',
          body:
              'This Agreement is between {{brand}} and {{creator}} for deliverables under collaboration {{collabId}}.',
          parameters: const ['brand', 'creator', 'collabId', 'amount'],
          version: '1.0',
          isActive: true,
          createdAt: DateTime.now().toUtc().toIso8601String(),
        ),
        const ContractTemplate(
          id: 'tmpl-demo-2',
          key: 'barter_v1',
          name: 'Barter Collaboration',
          body:
              'Barter terms: product {{product}} valued at {{value}} in exchange for content.',
          parameters: ['product', 'value'],
          version: '1.0',
          isActive: true,
        ),
      ]);
    }
  }

  Contract? _byCollab(String collaborationId) => _store.findWhere<Contract>(
        'contracts',
        (c) => c.collaborationId == collaborationId,
      );

  Contract _replace(Contract c) {
    _store.replaceWhere<Contract>('contracts', (x) => x.id == c.id, c);
    return c;
  }

  @override
  Future<Contract> get(String collaborationId) async {
    await _store.delay();
    _ensureFixtures();
    final c = _byCollab(collaborationId);
    if (c == null) {
      throw NotFoundFailure(
        'Contract not found for collaboration: $collaborationId',
      );
    }
    return c;
  }

  @override
  Future<Contract> accept({
    required String collaborationId,
    required String contentHash,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final c = _byCollab(collaborationId);
    if (c == null) {
      throw NotFoundFailure(
        'Contract not found for collaboration: $collaborationId',
      );
    }
    if (c.isReadOnly && c.isAccepted) {
      throw const ConflictFailure('Contract already accepted');
    }
    if (c.status == 'void') {
      throw const ConflictFailure('Contract is void');
    }
    if (contentHash.trim().isEmpty) {
      throw const ValidationFailure('contentHash is required');
    }
    if (contentHash != c.contentHash) {
      throw const ConflictFailure(
        'Content hash mismatch — reload contract before accepting',
        errorCode: 'HASH_MISMATCH',
      );
    }

    final userId = _store.currentUserId ?? MockIds.brand1;
    final party = _inferParty(userId);

    if (c.hasPartyAccepted(party)) {
      throw ConflictFailure('Party $party already accepted');
    }

    final acceptance = ContractAcceptance(
      party: party,
      acceptedByUserId: userId,
      contentHash: contentHash,
      acceptedAt: DateTime.now().toUtc().toIso8601String(),
    );
    final acceptances = [...c.acceptances, acceptance];

    // Demo convenience: first accept can complete if the other side is
    // already present, otherwise auto-complete after both parties, or
    // after a second call. For spine demos, accept once → both sides done
    // when at least one brand + one creator acceptance exists OR we
    // synthesize the counterparty on second distinct party.
    final parties = acceptances.map((a) => a.party).toSet();
    final both = parties.contains('brand') && parties.contains('creator');

    // Auto-add counterparty for smooth offline demo after first accept.
    final finalAcceptances = both
        ? acceptances
        : [
            ...acceptances,
            ContractAcceptance(
              party: party == 'brand' ? 'creator' : 'brand',
              acceptedByUserId:
                  party == 'brand' ? MockIds.creator1 : MockIds.brand1,
              contentHash: contentHash,
              acceptedAt: DateTime.now().toUtc().toIso8601String(),
            ),
          ];

    final updated = Contract(
      id: c.id,
      collaborationId: c.collaborationId,
      status: 'accepted',
      contentHash: c.contentHash,
      templateKey: c.templateKey,
      templateVersion: c.templateVersion,
      pdfUrl: c.pdfUrl,
      usageRights: c.usageRights,
      acceptances: finalAcceptances,
      bothPartiesAccepted: true,
    );
    return _replace(updated);
  }

  String _inferParty(String userId) {
    final account = _store.findAccountById(userId);
    final role = account?.user.role;
    if (role != null && role.isCreator) return 'creator';
    return 'brand';
  }

  @override
  Future<Contract> generate(String collaborationId) async {
    await _store.delay();
    _ensureFixtures();

    final existing = _byCollab(collaborationId);
    if (existing != null) {
      if (existing.status == 'void') {
        // regenerate
      } else {
        return existing;
      }
    }

    final contract = Contract(
      id: collaborationId == MockIds.collab1
          ? MockIds.contract1
          : 'contract-mock-${DateTime.now().microsecondsSinceEpoch}',
      collaborationId: collaborationId,
      status: 'generated',
      contentHash:
          'sha256-demo-${collaborationId.hashCode.toRadixString(16)}',
      templateKey: 'standard_paid_v1',
      templateVersion: '1.0',
      usageRights: const UsageRights(
        organicReuse: true,
        paidAmplification: false,
        durationDays: 90,
        territory: 'IN',
        channels: ['instagram'],
      ),
    );

    if (existing != null) {
      return _replace(contract);
    }
    _store.add('contracts', contract);
    return contract;
  }

  @override
  Future<List<ContractTemplate>> getTemplates() async {
    await _store.delay();
    _ensureFixtures();
    return _store.list<ContractTemplate>('contract_templates');
  }

  @override
  Future<ContractTemplate> createTemplate(Map<String, dynamic> data) async {
    await _store.delay();
    _ensureFixtures();

    final key = (data['key'] as String?)?.trim() ?? '';
    final name = (data['name'] as String?)?.trim() ?? '';
    final body = (data['body'] as String?)?.trim() ?? '';
    if (key.isEmpty || name.isEmpty || body.isEmpty) {
      throw const ValidationFailure('key, name, and body are required');
    }

    final tmpl = ContractTemplate(
      id: 'tmpl-mock-${DateTime.now().microsecondsSinceEpoch}',
      key: key,
      name: name,
      body: body,
      parameters: (data['parameters'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      version: (data['version'] as String?) ?? '1.0',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    _store.add('contract_templates', tmpl);
    return tmpl;
  }

  @override
  Future<ContractTemplate> updateTemplate(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _store.delay();
    _ensureFixtures();

    final existing = _store.findWhere<ContractTemplate>(
      'contract_templates',
      (t) => t.id == id,
    );
    if (existing == null) {
      throw NotFoundFailure('Contract template not found: $id');
    }

    final updated = existing.copyWith(
      key: data['key'] as String?,
      name: data['name'] as String?,
      body: data['body'] as String?,
      parameters: (data['parameters'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      version: data['version'] as String?,
      isActive: data['isActive'] as bool?,
    );
    _store.replaceWhere<ContractTemplate>(
      'contract_templates',
      (t) => t.id == id,
      updated,
    );
    return updated;
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _store.delay();
    _ensureFixtures();
    final existing = _store.findWhere<ContractTemplate>(
      'contract_templates',
      (t) => t.id == id,
    );
    if (existing == null) {
      throw NotFoundFailure('Contract template not found: $id');
    }
    _store.removeWhere<ContractTemplate>('contract_templates', (t) => t.id == id);
  }

  @override
  Future<List<ContractAmendment>> getAmendments(String contractId) async {
    await _store.delay();
    _ensureFixtures();
    return _store
        .list<ContractAmendment>('contract_amendments')
        .where((a) => a.contractId == contractId)
        .toList();
  }

  @override
  Future<ContractAmendment> requestAmendment({
    required String contractId,
    required String collaborationId,
    required String title,
    required String reason,
    required String amendedTerms,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final contract = _store.findWhere<Contract>(
      'contracts',
      (c) => c.id == contractId,
    );
    if (contract == null) {
      throw NotFoundFailure('Contract not found: $contractId');
    }
    if (title.trim().isEmpty || reason.trim().isEmpty) {
      throw const ValidationFailure('title and reason are required');
    }

    final amendment = ContractAmendment(
      id: 'amend-mock-${DateTime.now().microsecondsSinceEpoch}',
      contractId: contractId,
      collaborationId: collaborationId,
      title: title.trim(),
      reason: reason.trim(),
      amendedTerms: amendedTerms,
      status: 'pending',
      requestedBy: _store.currentUserId ?? MockIds.brand1,
      requestedAt: DateTime.now().toUtc().toIso8601String(),
    );
    _store.add('contract_amendments', amendment);
    return amendment;
  }

  @override
  Future<ContractAmendment> respondAmendment({
    required String contractId,
    required String amendmentId,
    required String status,
    String? notes,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final existing = _store.findWhere<ContractAmendment>(
      'contract_amendments',
      (a) => a.id == amendmentId && a.contractId == contractId,
    );
    if (existing == null) {
      throw NotFoundFailure('Amendment not found: $amendmentId');
    }
    if (!existing.isPending) {
      throw const ConflictFailure('Amendment is not pending');
    }
    if (status != 'approved' && status != 'rejected') {
      throw const ValidationFailure('status must be approved or rejected');
    }

    final updated = ContractAmendment(
      id: existing.id,
      contractId: existing.contractId,
      collaborationId: existing.collaborationId,
      title: existing.title,
      reason: existing.reason,
      amendedTerms: existing.amendedTerms,
      status: status,
      requestedBy: existing.requestedBy,
      requestedAt: existing.requestedAt,
      respondedAt: DateTime.now().toUtc().toIso8601String(),
      adminNotes: notes ?? existing.adminNotes,
    );
    _store.replaceWhere<ContractAmendment>(
      'contract_amendments',
      (a) => a.id == amendmentId,
      updated,
    );
    return updated;
  }
}
