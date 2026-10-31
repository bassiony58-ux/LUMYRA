import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_badge.dart';

class JournalEntryItem {
  final String id;
  final String date;
  final String time;
  final String mood;
  final int painLevel;
  final List<String> tags;
  final String content;

  JournalEntryItem({
    required this.id,
    required this.date,
    required this.time,
    required this.mood,
    required this.painLevel,
    required this.tags,
    required this.content,
  });
}

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final List<JournalEntryItem> _entries = [
    JournalEntryItem(
      id: 'entry-1',
      date: 'اليوم، ٢٥ أكتوبر ٢٠٢٦',
      time: '٠٢:١٥ م',
      mood: '😊',
      painLevel: 1,
      tags: ['راحة', 'طاقة إيجابية', 'مشي'],
      content: 'شعرت بتحسن ملحوظ اليوم بعد المشي الصباحي. تناولت وجبة صحية والجرعة الصباحية في موعدها دون أي غثيان.',
    ),
    JournalEntryItem(
      id: 'entry-2',
      date: 'الخميس، ٢٣ أكتوبر ٢٠٢٦',
      time: '٠٩:٣٠ م',
      mood: '😔',
      painLevel: 4,
      tags: ['إرهاق', 'ألم خفيف بالثدي'],
      content: 'شديدة الإرهاق مساء اليوم، هناك وخز بسيط في الجانب الأيمن. دونت ذلك لسؤال د. نور في زيارة المتابعة القادمة.',
    ),
    JournalEntryItem(
      id: 'entry-3',
      date: 'الثلاثاء، ٢١ أكتوبر ٢٠٢٦',
      time: '١١:٠٠ ص',
      mood: '😌',
      painLevel: 2,
      tags: ['جلسة تأمل', 'نوم مريح'],
      content: 'نمت ٨ ساعات متواصلة لأول مرة هذا الأسبوع. الدعم العائلي اليوم كان له أثر كبير على راحتي النفسية.',
    ),
  ];

  String _selectedMood = '😊';
  double _painLevel = 2.0;
  final Set<String> _selectedTags = {'راحة'};
  final TextEditingController _noteController = TextEditingController();
  bool _isWritingNew = false;

  final List<Map<String, String>> _moods = [
    {'emoji': '😊', 'labelAr': 'هادئة ومستقرة', 'labelEn': 'Calm & Stable'},
    {'emoji': '😌', 'labelAr': 'مرتاحة', 'labelEn': 'Relaxed'},
    {'emoji': '😐', 'labelAr': 'عادية', 'labelEn': 'Neutral'},
    {'emoji': '😔', 'labelAr': 'قلقة أو متعبة', 'labelEn': 'Anxious/Fatigued'},
    {'emoji': '😣', 'labelAr': 'ألم خفيف', 'labelEn': 'Mild Discomfort'},
  ];

  final List<String> _availableTagsAr = [
    'راحة',
    'إرهاق',
    'ألم بالثدي',
    'تغير في النوم',
    'أعراض هرمونية',
    'غثيان',
    'طاقة إيجابية',
    'مشاعر قلق',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveNewEntry() {
    if (_noteController.text.trim().isEmpty) return;

    setState(() {
      _entries.insert(
        0,
        JournalEntryItem(
          id: 'entry-${DateTime.now().millisecondsSinceEpoch}',
          date: 'اليوم، ${DateTime.now().day} أكتوبر ٢٠٢٦',
          time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          mood: _selectedMood,
          painLevel: _painLevel.round(),
          tags: _selectedTags.toList(),
          content: _noteController.text.trim(),
        ),
      );
      _noteController.clear();
      _isWritingNew = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.isArabic ? 'تم حفظ التدوينة بنجاح في سجلكِ الخاص المشفر 🌸' : 'Journal entry safely saved and encrypted 🌸',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: 4,
      titleKey: 'navJournal',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Privacy Header
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.powderBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.lock_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.isArabic ? 'يومياتي الخاصة المشفرة' : 'Private Encrypted Journal',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.isArabic
                                  ? 'سجلكِ محمي بتشفير تام، ولا يشارك مع أي طرف إلا بموافقتكِ الصريحة.'
                                  : 'Protected with end-to-end encryption. Visible only to you.',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge.active(context.isArabic ? 'مشفر ٢٥٦-بت' : '256-bit Encrypted'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!_isWritingNew)
                    PillButton(
                      label: context.isArabic ? 'تدوين شعور أو عرض جديد' : 'New Journal Entry',
                      icon: Icons.edit_note_rounded,
                      onPressed: () => setState(() => _isWritingNew = true),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // New Entry Composer Card
            if (_isWritingNew) ...[
              AppCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.isArabic ? 'كيف تشعرين اليوم؟' : 'How are you feeling today?',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.mainText),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => setState(() => _isWritingNew = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Mood Selector
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _moods.map((m) {
                          final isSelected = _selectedMood == m['emoji'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('${m['emoji']}  ${context.isArabic ? m['labelAr'] : m['labelEn']}'),
                              selected: isSelected,
                              selectedColor: AppColors.powderBackground,
                              backgroundColor: AppColors.whiteSurface,
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.primary : AppColors.secondaryText,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 13,
                              ),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : AppColors.warmNeutralSand,
                                width: isSelected ? 1.5 : 1,
                              ),
                              onSelected: (_) => setState(() => _selectedMood = m['emoji']!),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Pain / Discomfort Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.isArabic ? 'مستوى الانزعاج أو الألم:' : 'Discomfort / Pain Level:',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${_painLevel.round()} / ١٠',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ],
                    ),
                    Slider(
                      value: _painLevel,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      activeColor: AppColors.primaryAction,
                      inactiveColor: AppColors.warmNeutralSand,
                      onChanged: (val) => setState(() => _painLevel = val),
                    ),
                    const SizedBox(height: 14),
                    // Symptoms / Tags
                    Text(
                      context.isArabic ? 'أعراض أو ملاحظات سريعة:' : 'Tags & Symptoms:',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTagsAr.map((tag) {
                        final isTagSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isTagSelected,
                          selectedColor: AppColors.primaryContainer.withAlpha(50),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isTagSelected ? AppColors.primary : AppColors.mainText,
                            fontWeight: isTagSelected ? FontWeight.w700 : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Note Text Field
                    TextField(
                      controller: _noteController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: context.isArabic
                            ? 'اكتبي ما يجول في خاطركِ، تفاصيل الأعراض، أو ما ترغبين في تذكره...'
                            : 'Write down your thoughts, symptoms, or anything you want to remember...',
                        fillColor: AppColors.powderBackground,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.warmNeutralSand),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primaryAction, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: PillButton(
                            label: context.isArabic ? 'حفظ التدوينة' : 'Save Entry',
                            icon: Icons.check_circle_rounded,
                            onPressed: _saveNewEntry,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => setState(() => _isWritingNew = false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.outline),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          child: Text(
                            context.isArabic ? 'إلغاء' : 'Cancel',
                            style: const TextStyle(color: AppColors.secondaryText),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Section Title: Past Entries
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.isArabic ? 'التدوينات السابقة (${_entries.length})' : 'Recent Entries (${_entries.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.mainText),
                ),
                Text(
                  context.isArabic ? 'مرتبة زمنياً' : 'Chronological',
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Entries List
            ..._entries.map((entry) {
              return AppCard(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.powderBackground,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(entry.mood, style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.date,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                              Text(
                                '${entry.time} • مستوى الانزعاج: ${entry.painLevel}/١٠',
                                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.secondaryText),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.content,
                      style: const TextStyle(fontSize: 14, color: AppColors.mainText, height: 1.5),
                    ),
                    if (entry.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: entry.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.powderBackground,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.warmNeutralSand),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w500),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
