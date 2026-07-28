import 'package:firebase_core/firebase_core.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message =
        'Sem conexão com o servidor agora. Tente novamente em instantes.',
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
  ]);
}

class PermissionFailure extends Failure {
  const PermissionFailure([
    super.message = 'Você não tem permissão pra fazer isso nessa conta.',
  ]);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Algo deu errado. Tente novamente.',
  ]);
}

/// Traduz uma exceção capturada num repositório para um [Failure] especifico,
/// usando o código de erro do Firebase quando disponível em vez de sempre
/// cair numa mensagem genérica.
Failure mapExceptionToFailure(Object error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return const PermissionFailure();
      case 'unavailable':
      case 'deadline-exceeded':
        return const NetworkFailure();
      default:
        return const ServerFailure();
    }
  }
  return const UnexpectedFailure();
}
