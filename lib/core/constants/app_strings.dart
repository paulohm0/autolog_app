class AppStrings {
  AppStrings._();

  // Brand
  static const String appBrandName = 'AutoLog';
  static const String appBrandNameSplit1 = "Auto";
  static const String appBrandNameSplit2 = "Log";

  // Login Screen
  static const String signInGoogleLabel = 'Entrar com o Google';
  static const String loginSubtitle =
      'Controle a manutenção do seu veículo em um só lugar.';
  static const String loginBenefitMaintenance =
      'Histórico completo de manutenções';
  static const String loginBenefitOilBattery =
      'Controle de troca de óleo e bateria';
  static const String loginBenefitMultiVehicle =
      'Gerencie todos os seus veículos em um só lugar';

  // Home Screen
  static const String activeVehiclesLabel = 'Meus Veículos';
  static const String maintenanceHistory = 'Histórico de Manutenção';
  static const String filters = 'Filtros';
  static const String allVehicles = 'Todos os Veículos';
  static const String allYears = 'Todos os Anos';
  static const String vehicleFilter = 'VEÍCULO';
  static const String yearFilter = 'ANO';
  static const String applyFiltersButton = 'Aplicar Filtros';
  static const String emptyMaintenanceHistory =
      'Nenhuma manutenção registrada ainda.';
  static const String maintenanceTotalLabel = 'Total:';

  // Register Vehicle Screen
  static const String vehicleSection = 'VEÍCULO';
  static const String registerVehicleTitle = 'Registrar Veículo';
  static const String brandLabel = 'Marca';
  static const String brandHint = 'Ex: Fiat, Chevrolet';
  static const String modelLabel = 'Modelo';
  static const String modelHint = 'Ex: Uno, Camaro';
  static const String plateLabel = 'Placa';
  static const String plateHint = 'ABC 1234 ou ABC 1D23';
  static const String optionalDetails = 'Detalhes Opcionais';
  static const String yearLabel = 'ANO';
  static const String yearHint = '2024';
  static const String colorLabel = 'COR';
  static const String colorHint = 'Prata';
  static const String saveVehicleButton = 'Salvar Veículo';
  static const String saveVehicleSnackBarMessage = 'Veículo salvo com sucesso!';
  static const String saveVehicleDescription =
      'Ao salvar, este veículo será adicionado à sua\ngaragem digital e sincronizado com sua conta.';
  static const String editVehicleTitle = 'Editar Veículo';
  static const String updateVehicleButton = 'Salvar Alterações';
  static const String updateVehicleSnackBarMessage =
      'Veículo atualizado com sucesso!';
  static const String deleteVehicleSnackBarMessage =
      'Veículo excluído com sucesso!';
  static const String deleteVehicleConfirmTitle = 'Excluir veículo?';
  static const String myVehiclesTitle = 'Meus Veículos';
  static const String addVehicleLabel = 'Adicionar Veículo';
  static const String deleteVehicleWithRecordsTitle =
      'Este veículo possui registros vinculados';
  static const String deleteVehicleWithRecordsWarning =
      'Ao excluir, todos os registros abaixo também serão excluídos permanentemente:';
  static const String deleteVehicleWithRecordsConfirmButton = 'Excluir tudo';

  // Register Service Screen
  static const String maintenanceSection = 'MANUTENÇÃO';
  static const String registerServiceTitle = 'Registrar Serviço';
  static const String vehicleLabel = 'Veículo';
  static const String selectCarHint = 'Selecione o carro';
  static const String maintenanceDateLabel = 'DATA DA MANUTENÇÃO';
  static const String dateHint = 'dd/mm/aaaa';
  static const String workshopLabel = 'Oficina / Estabelecimento';
  static const String workshopHint = 'Ex: Performance Garage SP';
  static const String serviceValueLabel = "VALOR DO SERVIÇO";
  static const String servicesDescriptionLabel =
      'Descrição dos Serviços e Peças';
  static const String servicesDescriptionHint =
      'Ex: Troca de óleo\nTroca do filtro de ar\nAlinhamento e balanceamento';
  static const String servicesDescriptionCaption =
      'Dica: aperte Enter para separar cada item em uma linha.';
  static const String totalValueLabel = 'VALOR TOTAL';
  static const String moneySignLabel = 'R\$';
  static const String saveMaintenanceButton = 'Salvar Manutenção';
  static const String valueWarning =
      '* O valor inserido será contabilizado no seu relatório anual de gastos automotivos automaticamente.';
  static const String saveMaintenanceSnackBarMessage =
      'Manutenção salva com sucesso!';
  static const String noVehiclesRegistered =
      'Nenhum veículo cadastrado. Cadastre um veículo primeiro.';
  static const String editMaintenanceTitle = 'Editar Manutenção';
  static const String updateMaintenanceButton = 'Salvar Alterações';
  static const String updateMaintenanceSnackBarMessage =
      'Manutenção atualizada com sucesso!';
  static const String deleteMaintenanceSnackBarMessage =
      'Manutenção excluída com sucesso!';
  static const String deleteConfirmTitle = 'Excluir manutenção?';
  static const String deleteConfirmMessage = 'Essa ação não pode ser desfeita.';
  static const String editButton = 'Editar';
  static const String deleteButton = 'Excluir';
  static const String cancelButton = 'Cancelar';

  // Oil/Battery Screen (histórico derivado das manutenções marcadas — ver
  // Campos de óleo/bateria abaixo, dentro do formulário de Manutenção)
  static const String oilToggleLabel = 'Óleo';
  static const String batteryToggleLabel = 'Bateria';
  static const String oilChangeHistoryTitle = 'Histórico de Troca de Óleo';
  static const String batteryChangeHistoryTitle =
      'Histórico de Troca de Bateria';
  static const String emptyOilChangeHistory =
      'Nenhuma troca de óleo registrada ainda.';
  static const String emptyBatteryChangeHistory =
      'Nenhuma troca de bateria registrada ainda.';
  static const String emptyFilteredHistory =
      'Nenhum registro encontrado para esse filtro.';

  // Campos de óleo/bateria dentro do formulário de Manutenção
  static const String hasOilChangeLabel = 'Houve troca de óleo?';
  static const String hasBatteryChangeLabel = 'Houve troca de bateria?';
  static const String oilBrandLabel = 'Marca do Óleo';
  static const String oilBrandHint = 'Ex: Mobil, Castrol';
  static const String litersLabel = 'Litros';
  static const String litersHint = 'Ex: 4,5';
  static const String batteryModelLabel = 'Modelo da Bateria';
  static const String batteryModelHint = 'Ex: Moura 60Ah';
  static const String batteryCapacityLabel = 'Capacidade da Bateria';
  static const String batteryCapacityHint = 'Ex: 60Ah, 12V 60Ah';

  // Profile Screen
  static const String appVersionLabel = 'Versão do App';
  static const String signOutButton = 'Sair';
  static const String themeSectionLabel = 'Modo Dark';

  // Main Navigation
  static const String navHistoryLabel = 'Histórico';
  static const String navOilBatteryLabel = 'Óleo/Bateria';
  static const String navProfileLabel = 'Perfil';

  // Validação de formulários
  static const String requiredFieldError = 'Campo obrigatório';
  static const String valueMustBePositive = 'Informe um valor maior que zero';

  // Onboarding (cadastro do primeiro veículo)
  static const String onboardingVehicleTitle = 'Vamos começar!';
  static const String onboardingVehicleMessage =
      'Cadastre seu primeiro veículo para começar, ou pule por enquanto e cadastre depois.';
  static const String retryButton = 'Tentar novamente';
  static const String skipButton = 'Pular';

  // Popup de veículo ausente na Home
  static const String noVehicleDialogTitle = 'Nenhum veículo cadastrado';
  static const String noVehicleDialogMessage =
      'Cadastre um veículo para começar a registrar suas manutenções, trocas de óleo e bateria.';
  static const String laterButton = 'Agora não';

  // AuthGate (splash)
  static const String authGateErrorMessage =
      'Não foi possível conectar. Verifique sua internet e tente novamente.';

  // Confirmação de saída do app
  static const String exitAppConfirmTitle = 'Sair do app?';
  static const String exitAppConfirmMessage =
      'Você será direcionado para fora do AutoLog.';
  static const String exitAppButton = 'Sair';
}
