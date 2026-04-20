class Country {
  final String code;
  final String name;
  final String flag;
  const Country(this.code, this.name, this.flag);
}

const popularCountries = <Country>[
  Country('US', 'United States', '🇺🇸'),
  Country('JP', 'Japan', '🇯🇵'),
  Country('CN', 'China', '🇨🇳'),
  Country('TW', 'Taiwan', '🇹🇼'),
  Country('HK', 'Hong Kong', '🇭🇰'),
  Country('SG', 'Singapore', '🇸🇬'),
  Country('MY', 'Malaysia', '🇲🇾'),
  Country('ID', 'Indonesia', '🇮🇩'),
  Country('TH', 'Thailand', '🇹🇭'),
  Country('VN', 'Vietnam', '🇻🇳'),
  Country('PH', 'Philippines', '🇵🇭'),
  Country('IN', 'India', '🇮🇳'),
  Country('SA', 'Saudi Arabia', '🇸🇦'),
  Country('AE', 'UAE', '🇦🇪'),
  Country('TR', 'Turkey', '🇹🇷'),
  Country('RU', 'Russia', '🇷🇺'),
  Country('GB', 'United Kingdom', '🇬🇧'),
  Country('DE', 'Germany', '🇩🇪'),
  Country('FR', 'France', '🇫🇷'),
  Country('IT', 'Italy', '🇮🇹'),
  Country('ES', 'Spain', '🇪🇸'),
  Country('NL', 'Netherlands', '🇳🇱'),
  Country('CA', 'Canada', '🇨🇦'),
  Country('MX', 'Mexico', '🇲🇽'),
  Country('BR', 'Brazil', '🇧🇷'),
  Country('AR', 'Argentina', '🇦🇷'),
  Country('AU', 'Australia', '🇦🇺'),
  Country('NZ', 'New Zealand', '🇳🇿'),
  Country('EG', 'Egypt', '🇪🇬'),
  Country('ZA', 'South Africa', '🇿🇦'),
  Country('OT', 'Other', '🌍'),
];

class Occupation {
  final String code;
  final String label;
  const Occupation(this.code, this.label);
}

const occupations = <Occupation>[
  Occupation('student',  'Student'),
  Occupation('office',   'Office worker'),
  Occupation('it',       'IT / Engineering'),
  Occupation('finance',  'Finance'),
  Occupation('medical',  'Medical / Healthcare'),
  Occupation('edu',      'Education'),
  Occupation('self',     'Self-employed'),
  Occupation('creative', 'Creative / Media'),
  Occupation('service',  'Service / Hospitality'),
  Occupation('other',    'Other'),
];

const ageBuckets = <String>['18-24', '25-34', '35-44', '45-54', '55+'];
