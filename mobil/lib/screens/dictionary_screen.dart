
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dictionary_provider.dart';
import '../providers/locale_provider.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  String _selectedPrimaryLang = 'uz';

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLangChip('uz', localeProvider.getText('uzbek')),
                        const SizedBox(width: 8),
                        _buildLangChip('en', localeProvider.getText('english')),
                        const SizedBox(width: 8),
                        _buildLangChip('ru', localeProvider.getText('russian')),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 4.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: localeProvider.getText('search_hint'),
                    prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    context.read<DictionaryProvider>().search(value);
                  },
                ),
              ),
            ),
          ),
          Consumer<DictionaryProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              }
              final wordsList = provider.words;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final word = wordsList[index];
                    
                    String mainWord;
                    List<Map<String, String>> subs = [];

                    if (_selectedPrimaryLang == 'uz') {
                      mainWord = word.uz;
                      subs = [{'l': 'EN', 't': word.en, 'c': '0xFF1B5E20'}, {'l': 'RU', 't': word.ru, 'c': '0xFFB71C1C'}];
                    } else if (_selectedPrimaryLang == 'en') {
                      mainWord = word.en;
                      subs = [{'l': 'UZ', 't': word.uz, 'c': '0xFF1A237E'}, {'l': 'RU', 't': word.ru, 'c': '0xFFB71C1C'}];
                    } else { // ru
                      mainWord = word.ru;
                      subs = [{'l': 'UZ', 't': word.uz, 'c': '0xFF1A237E'}, {'l': 'EN', 't': word.en, 'c': '0xFF1B5E20'}];
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.withOpacity(0.1),
                          child: Text(
                            mainWord.isNotEmpty ? mainWord[0].toUpperCase() : '?', 
                            style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)
                          ),
                        ),
                        title: Text(mainWord, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF212121))),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: subs.map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: _buildLangRow(s['l']!, s['t']!, Color(int.parse(s['c']!))),
                            )).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: wordsList.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLangChip(String code, String label) {
    bool isSelected = _selectedPrimaryLang == code;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedPrimaryLang = code);
      },
      selectedColor: Colors.indigo,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      backgroundColor: Colors.indigo.withOpacity(0.05),
    );
  }

  Widget _buildLangRow(String label, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16, color: Color(0xFF424242)))),
      ],
    );
  }
}
