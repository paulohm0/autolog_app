# <p align="center"> AutoLog

Aplicativo para controle e registro detalhado de manutenções veiculares — histórico de serviços, troca de óleo e bateria, e gastos por veículo, tudo num só lugar.

O objetivo do projeto foi ir além de "só fazer funcionar": aprender e aplicar Clean Architecture com boas práticas de verdade num app Flutter completo, e percorrer o fluxo real de preparação de um app para publicação em loja (identidade visual, assinatura de release, política de privacidade, exigências de segurança e dados).

## > Funcionalidades

- Cadastro de múltiplos veículos, cada um com seu próprio histórico
- Histórico de manutenções (data, oficina, descrição, valor)
- Controle de troca de óleo e bateria, vinculado à manutenção correspondente
- Total de gastos com filtros por veículo e por ano
- Modo claro e escuro, adaptado automaticamente ao tema do sistema
- Login social com Google
- Exclusão de conta e de todos os dados diretamente pelo app

## > Arquitetura

Clean Architecture, em quatro camadas:

```
lib/
  core/      # DI, tema, constantes, utilitários — configuração interna do app
  domain/    # Dart puro — entidades e interfaces de repositório, sem Flutter/Firebase
  data/      # Implementação dos repositórios, models e comunicação com o Firebase
  ui/        # Telas e widgets — cada tela com seu Cubit + State e componentes
```

## > Tech Stack

- Flutter / Dart
- Firebase (Authentication, Firestore, Crashlytics)
- flutter_bloc (Cubit)
- get_it
- dartz
- google_sign_in
- shared_preferences
- cached_network_image

**Testes:** mocktail · bloc_test · fake_cloud_firestore · firebase_auth_mocks

## > Padrões e decisões técnicas

- **Repository Pattern**: interfaces no `domain`, implementação concreta (Firebase) isolada no `data`, o resto do app não sabe que o Firestore existe
- **Either/Failure** (`dartz`) para tratamento de erro nos repositórios, sem exceções vazando pra UI
- **Cubits** (`flutter_bloc`) por tela, com estados tipados (`Initial`, `Loading`, `Loaded`, `Error`)
- **get_it** para injeção de dependência, repositórios como singletons e Cubits como factories
- **Isolamento de dados por usuário** via subcoleções no Firestore (`users/{uid}/vehicles`, `users/{uid}/maintenances`), reforçado por regras de segurança no servidor
- **`ThemeExtension`** nativa do Flutter para o modo escuro, em vez de expor cores via Cubit
- **Cache local com proteção contra fetch duplicado**: mostra dados instantaneamente ao abrir o app enquanto atualiza em segundo plano, sem disparar requisições concorrentes quando duas telas pedem os mesmos dados ao mesmo tempo
- **Persistência local mínima**: `shared_preferences` é usado só para guardar a preferência de tema (claro/escuro/sistema) entre sessões, todo o resto dos dados do app vive no Firestore
- **Exclusão em cascata coordenada no Cubit**: apagar um veículo ou a conta remove primeiro os registros vinculados no Firestore, e só then a entidade principal
- **Updates otimistas** em telas de cadastro — a navegação não espera a confirmação do servidor, seguida de tratamento de erro caso a operação falhe depois
- **Formatadores de input customizados** (`TextInputFormatter`) para placa de veículo e valores monetários, com testes cobrindo casos de edição no meio do texto
- **Composição de widgets em vez de métodos `_build`**: cada trecho reutilizável de UI vira uma classe própria (`Stateless`/`StatefulWidget`), nunca um método privado retornando `Widget`

## > IA no fluxo de desenvolvimento

O projeto foi desenvolvido com apoio do Claude Code, mas de forma estruturada.

- **3 agentes especializados**, cada um com escopo e responsabilidade próprios:
  - **Planner**: quebra requisitos em tarefas, define abordagem antes de qualquer código ser escrito
  - **Features**: implementa seguindo a arquitetura e os padrões já definidos no projeto
  - **Tests**: escreve e valida os testes de cada funcionalidade, cobrindo os cenários definidos pelo Planner
- **MCP do Firebase conectado**, permitindo que os agentes consultassem a estrutura real do
  projeto (coleções, regras de segurança, configuração do Firestore/Auth) durante o
  desenvolvimento, em vez de gerar código baseado em suposições genéricas sobre o Firebase
- Todo código gerado foi **revisado, ajustado e entendido** antes de ser incorporado — a IA
  acelerou a execução, mas as decisões de arquitetura e os padrões do projeto foram definidos
  e validados por mim

## > Design System

O app segue um sistema de tokens de design próprio, em vez de valores soltos espalhados pelas telas — qualquer cor, espaçamento ou raio de borda vem de uma dessas constantes:

- **Cores semânticas** (`AppColorsExtension`) — tokens como `primary`, `background`, `surface`, `textPrimary`, `error`, `border`, com uma versão clara e uma escura para cada um, trocando automaticamente com o tema do sistema via `ThemeExtension` nativa do Flutter (`context.colors.primary`, por exemplo)
- **Tipografia** (`AppTextStyles`) — escala de 11 estilos (`displayLarge` → `labelMedium`), todos usando a fonte Inter
- **Espaçamento** (`AppSpacing`) — escala consistente de `xs` (4px) a `xxxxl` (64px)
- **Raio de borda** (`AppRadius`) — escala de `sm` a `full` (999, para elementos circulares)

Em cima desses tokens, um conjunto de widgets reutilizáveis (`AppTextField`, `PrimaryButton`, `SectionCard`, `DeleteConfirmDialog`, entre outros) garante que a aparência do app fique consistente sem repetir estilo em cada tela.

## > Testes

Cobertura em três camadas, refletindo o que cada uma realmente precisa:
- **Unitários**: funções puras (formatadores, mapeamento de erro) e todos os Cubits, com repositórios mockados (`mocktail` + `bloc_test`)
- **Widget**: comportamento de UI dependente de contexto (ex: tema do sistema), com `flutter_test`
- **Repositório**: `VehicleRepositoryImpl`/`MaintenanceRepositoryImpl` contra um Firestore simulado em memória (`fake_cloud_firestore`), incluindo isolamento entre usuários; `AuthRepositoryImpl` com `firebase_auth_mocks`

```bash
flutter test
```

## > Como rodar o projeto

Pré-requisitos: Flutter SDK instalado e um projeto Firebase configurado (Auth + Firestore).

```bash
git clone https://github.com/paulohm0/autolog_app.git
cd autolog_app
flutter pub get
flutter run
```

## > Status do projeto

Código e testes concluídos. Atualmente em **processo de preparação para publicação nas lojas**:

- ✅ Nome e ícone consistentes entre plataformas
- ✅ Assinatura de release configurada (Android)
- ✅ Política de privacidade publicada
- ✅ Fluxo de exclusão de conta implementado (exigência das lojas)
- ✅ Conta de desenvolvedor Google Play Console criada e verificada
- ✅ App criado no Play Console, com ficha da loja completa (ícone, feature graphic, screenshots, descrição, Data Safety, classificação indicativa)
- ✅ Login validado via Firebase Auth + Google Sign-In na versão distribuída pela loja
- ⏳ Teste fechado em andamento (exigência do Google antes de liberar produção)

## > Habilidades Testadas

- ✅ Clean Architecture (domain / data / ui)
- ✅ Gerenciamento de estado com Cubit (flutter_bloc)
- ✅ Injeção de dependência (get_it)
- ✅ Autenticação e banco de dados com Firebase
- ✅ Configuração de Firebase Crashlytics para logging de erros não-fatais em produção
- ✅ Testes unitários, de widget e de integração
- ✅ Modo escuro com `ThemeExtension` nativa
- ✅ Preparação de app para publicação em loja (assinatura, ícone, política de privacidade, conformidade de dados)

## > Imagens

<img width="300" alt="Screenshot_20260814_173349" src="https://github.com/user-attachments/assets/52613776-cdcf-428a-9e12-9fca6d897692" />
<img width="300" alt="Screenshot_20260814_173338" src="https://github.com/user-attachments/assets/15c33df3-dbdd-473a-a75b-e85a0dbe6749" />
<img width="300" alt="Screenshot_20260814_171517" src="https://github.com/user-attachments/assets/ab639023-1e84-4b71-8c9a-598ab2f3160e" />
<img width="300" alt="Screenshot_20260814_171241" src="https://github.com/user-attachments/assets/62435743-8b0c-409e-9ee5-bb8e0dc98688" />
<img width="300" alt="Screenshot_20260814_172049" src="https://github.com/user-attachments/assets/3965eee7-2dbd-4915-84d9-00f8f3c4c311" />


