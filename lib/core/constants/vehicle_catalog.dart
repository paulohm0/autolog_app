// Dados locais de marcas, modelos (só o nome principal, sem variação de
// motor/acabamento) e cores comuns, usados só pra sugerir enquanto o
// usuário digita no cadastro de veículo. Não é uma lista exaustiva — o
// campo sempre aceita texto livre, a sugestão é só uma ajuda.

const List<String> vehicleBrands = [
  'Audi',
  'BMW',
  'BYD',
  'Caoa Chery',
  'Chevrolet',
  'Citroën',
  'Fiat',
  'Ford',
  'GWM',
  'Honda',
  'Hyundai',
  'Jac',
  'Jeep',
  'Kia',
  'Land Rover',
  'Mercedes-Benz',
  'Mini',
  'Mitsubishi',
  'Nissan',
  'Peugeot',
  'Porsche',
  'RAM',
  'Renault',
  'Subaru',
  'Suzuki',
  'Toyota',
  'Troller',
  'Volkswagen',
  'Volvo',
];

const Map<String, List<String>> _modelsByBrand = {
  'Audi': ['A3', 'A4', 'A5', 'A6', 'Q3', 'Q5', 'Q7', 'Q8', 'TT'],
  'BMW': [
    'Série 1',
    'Série 2',
    'Série 3',
    'Série 4',
    'Série 5',
    'X1',
    'X2',
    'X3',
    'X5',
    'X6',
  ],
  'BYD': ['Dolphin', 'Dolphin Mini', 'Song Plus', 'Yuan Plus', 'Seal', 'King'],
  'Caoa Chery': [
    'Tiggo 3x',
    'Tiggo 5x',
    'Tiggo 7',
    'Tiggo 8',
    'Arrizo 5',
    'Arrizo 6',
    'QQ',
  ],
  'Chevrolet': [
    'Onix',
    'Onix Plus',
    'Prisma',
    'Celta',
    'Corsa',
    'Classic',
    'Cruze',
    'Cobalt',
    'Spin',
    'Tracker',
    'Trailblazer',
    'Equinox',
    'S10',
    'Montana',
    'Astra',
    'Vectra',
    'Camaro',
  ],
  'Citroën': ['C3', 'C4 Cactus', 'C4 Lounge', 'Aircross', 'Jumpy', 'Berlingo'],
  'Fiat': [
    'Uno',
    'Palio',
    'Siena',
    'Grand Siena',
    'Argo',
    'Cronos',
    'Mobi',
    'Toro',
    'Strada',
    'Doblò',
    'Fiorino',
    'Punto',
    'Idea',
    'Linea',
    'Bravo',
    'Ducato',
    'Pulse',
    'Fastback',
    '500',
  ],
  'Ford': [
    'Ka',
    'Ka Sedan',
    'Fiesta',
    'Focus',
    'Fusion',
    'EcoSport',
    'Ranger',
    'Territory',
    'Bronco',
    'Edge',
    'Escort',
    'Corcel',
    'Belina',
    'Maverick',
  ],
  'GWM': ['Haval H6', 'Ora 03', 'Poer', 'Tank 300'],
  'Honda': ['Civic', 'City', 'Fit', 'HR-V', 'CR-V', 'WR-V', 'Accord', 'ZR-V'],
  'Hyundai': [
    'HB20',
    'HB20S',
    'Creta',
    'Tucson',
    'Santa Fe',
    'i30',
    'ix35',
    'Elantra',
    'Azera',
  ],
  'Jac': ['T40', 'T50', 'T60', 'e-JS1', 'iEV40'],
  'Jeep': [
    'Renegade',
    'Compass',
    'Commander',
    'Wrangler',
    'Cherokee',
    'Gladiator',
  ],
  'Kia': ['Sportage', 'Cerato', 'Soul', 'Sorento', 'Picanto', 'Stonic', 'Niro'],
  'Land Rover': [
    'Discovery',
    'Discovery Sport',
    'Range Rover',
    'Range Rover Evoque',
    'Range Rover Velar',
    'Defender',
  ],
  'Mercedes-Benz': [
    'Classe A',
    'Classe C',
    'Classe E',
    'Classe S',
    'GLA',
    'GLB',
    'GLC',
    'Sprinter',
  ],
  'Mini': ['Cooper', 'Countryman', 'Clubman'],
  'Mitsubishi': [
    'L200 Triton',
    'Pajero',
    'Pajero Sport',
    'ASX',
    'Outlander',
    'Eclipse Cross',
    'Lancer',
  ],
  'Nissan': [
    'March',
    'Versa',
    'Sentra',
    'Kicks',
    'Frontier',
    'X-Trail',
    'Livina',
  ],
  'Peugeot': ['208', '2008', '3008', '408', '308', '207', '206', 'Partner'],
  'Porsche': ['911', 'Cayenne', 'Macan', 'Panamera', 'Taycan'],
  'RAM': ['1500', '2500', 'Rampage'],
  'Renault': [
    'Sandero',
    'Logan',
    'Duster',
    'Captur',
    'Kwid',
    'Oroch',
    'Stepway',
    'Fluence',
    'Clio',
    'Megane',
    'Symbol',
  ],
  'Subaru': ['Impreza', 'Forester', 'XV', 'Outback', 'Crosstrek'],
  'Suzuki': ['Vitara', 'Jimny', 'Swift', 'S-Cross'],
  'Toyota': [
    'Corolla',
    'Corolla Cross',
    'Etios',
    'Etios Cross',
    'Yaris',
    'Hilux',
    'SW4',
    'RAV4',
    'Camry',
    'Prius',
  ],
  'Troller': ['T4', 'Pantera'],
  'Volkswagen': [
    'Gol',
    'Voyage',
    'Fox',
    'Polo',
    'Virtus',
    'Golf',
    'Jetta',
    'T-Cross',
    'Nivus',
    'Saveiro',
    'Amarok',
    'Fusca',
    'Kombi',
    'Up',
    'SpaceFox',
    'CrossFox',
    'Tiguan',
    'Passat',
  ],
  'Volvo': ['XC40', 'XC60', 'XC90', 'S60', 'S90'],
};

const List<String> vehicleColors = [
  'Branco',
  'Preto',
  'Prata',
  'Cinza',
  'Grafite',
  'Vermelho',
  'Azul',
  'Azul Marinho',
  'Verde',
  'Verde Militar',
  'Amarelo',
  'Marrom',
  'Bege',
  'Dourado',
  'Laranja',
  'Roxo',
  'Vinho',
];

String _normalize(String value) {
  const accented = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  const plain = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
  var result = value.trim().toLowerCase();
  for (var i = 0; i < accented.length; i++) {
    result = result.replaceAll(accented[i], plain[i].toLowerCase());
  }
  return result;
}

/// Modelos base cadastrados pra [brandInput], comparando sem diferenciar
/// maiúscula/minúscula ou acento. Retorna lista vazia se a marca digitada
/// não bater com nenhuma marca conhecida (o campo de modelo continua
/// aceitando texto livre normalmente nesse caso).
List<String> modelsForBrand(String brandInput) {
  final normalizedInput = _normalize(brandInput);
  if (normalizedInput.isEmpty) return const [];
  for (final entry in _modelsByBrand.entries) {
    if (_normalize(entry.key) == normalizedInput) {
      return entry.value;
    }
  }
  return const [];
}

/// Filtra [options] pelas que contêm [query], ignorando maiúscula/minúscula
/// e acento. Usado pelo [AppAutocompleteField].
List<String> matchingOptions(List<String> options, String query) {
  final normalizedQuery = _normalize(query);
  if (normalizedQuery.isEmpty) return const [];
  return options
      .where((option) => _normalize(option).contains(normalizedQuery))
      .toList();
}
