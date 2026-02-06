import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_models.dart';
import '../services/storage_service.dart';
import '../providers/locale_provider.dart';
import 'test_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<TestCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      await _storage.initializeDefaults();
      final cats = await _storage.getCategories();
      setState(() {
        _categories = cats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() {
        _isLoading = false;
        // Optionally show error to user or empty list
        _categories = [];
      });
    }
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  Future<void> _addCategory() async {
    final lp = context.read<LocaleProvider>();
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lp.getText('add_section')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: lp.getText('add_section')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lp.getText('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _storage.createCategory(controller.text);
                _loadCategories();
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(lp.getText('save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LocaleProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lp.getText('app_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
          ? _buildEmptyState(lp)
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return _buildCategoryCard(cat, lp);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCategory,
        label: Text(lp.getText('add_section')),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(LocaleProvider lp) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '${lp.getText('sections')} yo\'q',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(TestCategory cat, LocaleProvider lp) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestListScreen(category: cat),
          ),
        ).then((_) => _loadCategories());
      },
      onLongPress: () => _confirmDelete(cat, lp),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder, size: 60, color: Colors.indigo),
            const SizedBox(height: 12),
            Text(
              cat.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            Text(
              '${cat.tests.length} ${lp.getText('questions')}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(TestCategory cat, LocaleProvider lp) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lp.getText('delete')),
        content: Text('"${cat.name}" o\'chib ketadi. Ishonchingiz komilmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lp.getText('cancel')),
          ),
          TextButton(
            onPressed: () async {
              await _storage.deleteCategory(cat.name);
              _loadCategories();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              lp.getText('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
