import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/task_provider.dart';
import '../core/theme/app_theme.dart';

/// پنل شناور با تب‌ها: تسک‌ها، لیست خرید، دفترچه، دستیار، ویجت‌ها
class FloatingPanel extends StatefulWidget {
  const FloatingPanel({super.key});

  @override
  State<FloatingPanel> createState() => _FloatingPanelState();
}

class _FloatingPanelState extends State<FloatingPanel> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();
  Timer? _saveTimer;
  List<String> _shopping = [];

  static const _kShoppingKey = 'shopping_list_v1';
  static const _kNotebookKey = 'notebook_v1';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadShopping();
    _loadNotebook();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    _saveTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadShopping() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kShoppingKey) ?? [];
    setState(() => _shopping = list);
  }

  Future<void> _saveShopping() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kShoppingKey, _shopping);
  }

  Future<void> _loadNotebook() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(_kNotebookKey) ?? '';
    _noteController.text = text;
    _noteController.addListener(_onNoteChanged);
  }

  void _onNoteChanged() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kNotebookKey, _noteController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: AppTheme.bgCard,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'مانا',
                      style: TextStyle(fontSize: 18, color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppTheme.textPrimary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryPurple,
              unselectedLabelColor: AppTheme.textSecondary,
              tabs: const [
                Tab(text: 'تسک‌ها'),
                Tab(text: 'لیست خرید'),
                Tab(text: 'دفترچه'),
                Tab(text: 'دستیار'),
                Tab(text: 'ویجت‌ها'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TasksTab(),
                  _ShoppingTab(onAdd: (item) async {
                    setState(() => _shopping.add(item));
                    await _saveShopping();
                  }, items: _shopping, onRemove: (i) async {
                    setState(() => _shopping.removeAt(i));
                    await _saveShopping();
                  }),
                  _NotebookTab(controller: _noteController),
                  _ManaAssistantTab(),
                  _WidgetCardsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final taskProv = Provider.of<TaskProvider>(context);
    final today = taskProv.getTodayTasks();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('تسک‌های امروز', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...today.map((t) => Card(
              color: AppTheme.bgCard,
              child: ListTile(
                title: Text(t.title, style: TextStyle(color: AppTheme.textPrimary)),
                subtitle: t.dueDate != null ? Text(t.dueDate.toString(), style: TextStyle(color: AppTheme.textSecondary)) : null,
                trailing: Checkbox(value: t.isCompleted, onChanged: (_) => taskProv.toggleTaskCompletion(t.id)),
              ),
            )),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/home'),
          child: const Text('رفتن به صفحه کامل تسک‌ها'),
        ),
      ],
    );
  }
}

class _ShoppingTab extends StatelessWidget {
  final void Function(String) onAdd;
  final List<String> items;
  final void Function(int) onRemove;

  _ShoppingTab({required this.onAdd, required this.items, required this.onRemove});

  final TextEditingController _ctl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: _ctl, decoration: const InputDecoration(hintText: 'افزودن آیتم'))),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final text = _ctl.text.trim();
                  if (text.isNotEmpty) {
                    onAdd(text);
                    _ctl.clear();
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) => Card(
                color: AppTheme.bgCard,
                child: ListTile(
                  title: Text(items[i], style: TextStyle(color: AppTheme.textPrimary)),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => onRemove(i)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotebookTab extends StatelessWidget {
  final TextEditingController controller;
  const _NotebookTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'دفترچه یادداشت...'),
            ),
          ),
          const SizedBox(height: 8),
          Text('ذخیره خودکار فعال است', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _ManaAssistantTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('دستیار مانا', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('این بخش بعداً با چت و هوش کلیپ‌بورد تکمیل می‌شود'),
          ],
        ),
      ),
    );
  }
}

class _WidgetCardsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      children: List.generate(6, (i) => Card(
            color: AppTheme.bgCard,
            child: Center(child: Text('ویجت ${i + 1}', style: TextStyle(color: AppTheme.textPrimary))),
          )),
    );
  }
}
