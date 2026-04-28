abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro ao comunicar com o servidor']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Erro inesperado']);
}
