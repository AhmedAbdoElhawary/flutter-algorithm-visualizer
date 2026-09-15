import 'package:algorithm_visualizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:algorithm_visualizer/features/auth/domain/services/guest_data_service.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';

/// Owns the one-way destruction of an account, in the order the pieces have to
/// go in.
///
/// It lives beside [GuestDataService] and for the same reason: the sequence is
/// destructive and order-sensitive, so it belongs in one named place rather
/// than spread across a notifier.
///
/// The order is not arbitrary:
///
/// 1. **Firestore first**, from inside the re-authenticated window. Deleting a
///    Firebase user does not cascade, and the security rules only admit writes
///    from the owning account — once the user is gone nothing may touch
///    `users/{uid}` ever again, so a subtree left behind is unreachable
///    garbage.
/// 2. **The Firebase user next**, which is the point of no return.
/// 3. **Local storage last.** It is the only step that cannot fail in a way
///    that matters: if the process dies here the account is already gone and
///    the next launch starts as a guest regardless.
class AccountDeletionService {
  AccountDeletionService({
    required AuthRepository authRepository,
    required ProblemRemoteDataSource problemRemoteDataSource,
    required GuestDataService guestDataService,
  })  : _authRepository = authRepository,
        _problemRemoteDataSource = problemRemoteDataSource,
        _guestDataService = guestDataService;

  final AuthRepository _authRepository;
  final ProblemRemoteDataSource _problemRemoteDataSource;
  final GuestDataService _guestDataService;

  /// Deletes the signed in account and everything stored for it.
  ///
  /// Throws if the password is wrong or the network is down, in which case
  /// nothing has been destroyed and the session is still usable.
  Future<void> deleteAccount({required String password}) async {
    await _authRepository.deleteAccount(
      password: password,
      onReauthenticated: _problemRemoteDataSource.deleteAllProblems,
    );

    /// Named for the guest session it usually clears, but the keys are the
    /// same ones an account writes locally, so this is also the right wipe
    /// after a deletion.
    await _guestDataService.clearGuestData();
  }
}
