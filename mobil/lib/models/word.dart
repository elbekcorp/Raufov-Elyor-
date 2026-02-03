
class Word {
  final String uz;
  final String en;
  final String ru;

  Word({required this.uz, required this.en, required this.ru});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      uz: json['u'] ?? json['uz'] ?? '',
      en: json['e'] ?? json['en'] ?? '',
      ru: json['r'] ?? json['ru'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'u': uz,
      'e': en,
      'r': ru,
    };
  }
}
