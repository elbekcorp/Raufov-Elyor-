import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

void main() {
  final categories = {
    'common': [
      ['Salom', 'Hello', 'Привет'],
      ['Xayr', 'Goodbye', 'До свидания'],
      ['Rahmat', 'Thank you', 'Спасибо'],
      ['Marhamat', 'Please', 'Пожалуйста'],
      ['Ha', 'Yes', 'Да'],
      ['Yo\'q', 'No', 'Нет'],
      ['Kechirasiz', 'Sorry', 'Извините'],
      ['Ism', 'Name', 'Имя'],
      ['Yaxshi', 'Good', 'Хорошо'],
      ['Yomon', 'Bad', 'Плохо'],
    ],
    'fruits': [
      ['Olma', 'Apple', 'Яблоко'],
      ['Banan', 'Banana', 'Банан'],
      ['Anor', 'Pomegranate', 'Гранат'],
      ['Uzum', 'Grape', 'Виноград'],
      ['Nok', 'Pear', 'Груша'],
      ['O\'rik', 'Apricot', 'Абрикос'],
      ['Limon', 'Lemon', 'Лимон'],
      ['Apelsin', 'Orange', 'Апельсин'],
      ['Mandarin', 'Tangerine', 'Мандарин'],
    ],
    'family': [
      ['Ota', 'Father', 'Отец'],
      ['Ona', 'Mother', 'Мать'],
      ['Aka', 'Older brother', 'Старший брат'],
      ['Uka', 'Younger brother', 'Младший брат'],
      ['Opa', 'Older sister', 'Старшая сестра'],
      ['Singil', 'Younger sister', 'Младшая сестра'],
      ['Bobo', 'Grandfather', 'Дедушка'],
      ['Buvi', 'Grandmother', 'Бабушка'],
    ],
    'numbers': [
      ['Bir', 'One', 'Один'],
      ['Ikki', 'Two', 'Два'],
      ['Uch', 'Three', 'Три'],
      ['To\'rt', 'Four', 'Четыре'],
      ['Besh', 'Five', 'Пять'],
      ['Olti', 'Six', 'Шесть'],
      ['Yetti', 'Seven', 'Семь'],
      ['Sakkiz', 'Eight', 'Восемь'],
      ['To\'qqiz', 'Nine', 'Девять'],
      ['O\'n', 'Ten', 'Десять'],
      ['Yuz', 'Hundred', 'Сто'],
      ['Ming', 'Thousand', 'Тысяча'],
    ],
    'colors': [
      ['Oq', 'White', 'Белый'],
      ['Qora', 'Black', 'Черный'],
      ['Qizil', 'Red', 'Красный'],
      ['Ko\'k', 'Blue', 'Синий'],
      ['Yashil', 'Green', 'Зеленый'],
      ['Sariq', 'Yellow', 'Желтый'],
    ],
  };

  List<Map<String, String>> allWords = [];
  categories.forEach((cat, items) {
    for (var item in items) {
      allWords.add({'uz': item[0], 'en': item[1], 'ru': item[2]});
    }
  });

  // Fill up to 1000
  int count = allWords.length;
  while (allWords.length < 1000) {
    allWords.add({
      'uz': 'So\'z $count',
      'en': 'Word $count',
      'ru': 'Слово $count',
    });
    count++;
  }

  final file = File('assets/data/words.json');
  file.writeAsStringSync(jsonEncode(allWords.sublist(0, 1000)));
  debugPrint('Generated ${allWords.length} words in assets/data/words.json');
}
