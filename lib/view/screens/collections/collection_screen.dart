// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/screens/dua/local%20stroge%20dua/user_added_dua_list_widget.dart';
import 'package:nazar_e_alam/view/screens/dhikr/local%20stroge%20dhikr/user_added_dikir_list_widget.dart';

typedef Json = Map<String, dynamic>;
const languages = {
  'en': 'English',
  'gu': 'ગુજરાતી',
  'hi': 'हिन्दी',
  'ur': 'اردو',
  'ar': 'العربية',
  'sw': 'Kiswahili',
};
String language(String? code) => switch (code) {
  'guj' => 'gu',
  'hin' => 'hi',
  'gu' || 'hi' || 'ur' || 'ar' || 'sw' => code!,
  _ => 'en',
};
String clean(dynamic v) => v is String ? v.trim() : '';
Json object(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : {};
List<Json> objects(dynamic v) =>
    v is List ? v.whereType<Map>().map(object).toList() : [];
String localized(dynamic v, String lang, {bool fallback = true}) {
  if (v is String) return clean(v);
  final m = object(v);
  final s = clean(m[lang]);
  return s.isNotEmpty || !fallback ? s : clean(m['en']);
}

String flat(Json v, String lang, String field, {bool fallback = true}) {
  final prefix = lang == 'gu'
      ? 'guj'
      : lang == 'hi'
      ? 'hin'
      : lang;
  final s = clean(v['${prefix}_$field']);
  return s.isNotEmpty || !fallback ? s : clean(v['en_$field']);
}

String name(Json v, String lang) => v.containsKey('title')
    ? localized(v['title'], lang)
    : flat(v, lang, 'short_name');
String identity(Json v, String kind) => '$kind:${v['id']}';

class CollectionScreen extends StatefulWidget {
  final bool dhikr, modern, appBackButton;
  const CollectionScreen({
    super.key,
    required this.dhikr,
    required this.modern,
    required this.appBackButton,
  });
  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final prefs = Get.find<SharedPreferences>();
  final api = Get.find<ApiClient>();
  final scroll = ScrollController();
  final search = TextEditingController();
  final data = <String, List<Json>>{};
  final errors = <String>{};
  final loading = <String>{};
  List<String> get endpoints =>
      widget.dhikr ? ['dhikrs'] : ['masnoon-duas', 'duas', 'dua-categories'];
  bool favorites = false;
  late Set<String> saved = (prefs.getStringList('collection.saved.v1') ?? [])
      .toSet();
  String get lang => language(Get.locale?.languageCode);
  @override
  void initState() {
    super.initState();
    for (final endpoint in endpoints) {
      load(endpoint);
    }
  }

  @override
  void dispose() {
    scroll.dispose();
    search.dispose();
    super.dispose();
  }

  Future<void> load(String endpoint, {bool refresh = false}) async {
    if (loading.contains(endpoint)) return;
    setState(() {
      loading.add(endpoint);
      errors.remove(endpoint);
    });
    try {
      final rows = <Json>[];
      int skip = 0;
      while (true) {
        final r = await api.getData(
          endpoint,
          query: endpoint == 'dua-categories'
              ? null
              : {'limit': 500, 'skip': skip},
          cacheDuration: const Duration(hours: 1),
          offlineFallback: true,
          forceRefresh: refresh,
        );
        if (r.statusCode != 200) throw StateError('HTTP ${r.statusCode}');
        final body = r.body;
        if (body is! List && (body is! Map || body['items'] is! List)) {
          throw const FormatException('Invalid collection');
        }
        final batch = objects(body is List ? body : body['items']);
        rows.addAll(batch);
        final total = object(object(body)['meta'])['total'];
        if (body is List ||
            batch.isEmpty ||
            total is! num ||
            rows.length >= total) {
          break;
        }
        skip += batch.length;
      }
      if (mounted) setState(() => data[endpoint] = rows);
    } catch (_) {
      if (mounted) setState(() => errors.add(endpoint));
    } finally {
      if (mounted) setState(() => loading.remove(endpoint));
    }
  }

  Future<void> refresh() async {
    await Future.wait(endpoints.map((e) => load(e, refresh: true)));
  }

  void toggle(Json item, String kind) {
    final key = identity(item, kind);
    setState(() {
      if (!saved.add(key)) saved.remove(key);
    });
    prefs.setStringList('collection.saved.v1', saved.toList());
  }

  Future<void> open(List<Json> rows, int index, String kind) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CollectionReader(
          rows: rows,
          index: index,
          kind: kind,
          modern: widget.modern,
        ),
      ),
    );
    if (mounted) {
      setState(
        () =>
            saved = (prefs.getStringList('collection.saved.v1') ?? []).toSet(),
      );
    }
  }

  void personal() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: CustomAppBar(
            title: (widget.dhikr ? 'added_dhikr' : 'added_dua').tr,
            isBackButtonExist: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => Get.toNamed(
                  widget.dhikr ? RouteHelper.addDhikr : RouteHelper.duaAdd,
                ),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: widget.dhikr ? UserAddedDikirWidget() : UserAddedDuaWidget(),
          ),
        ),
      ),
    );
  }

  Widget heading(String title, {String? count}) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (count != null)
          Text(count, style: Theme.of(context).textTheme.labelLarge),
      ],
    ),
  );
  Widget tile(List<Json> rows, int i, String kind) {
    final v = rows[i];
    final t = Theme.of(context);
    final ar = kind == 'masnoon-duas'
        ? clean(
            (objects(object(v['content'])['recitations']).isEmpty
                ? <String, dynamic>{}
                : objects(object(v['content'])['recitations']).first)['arabic'],
          )
        : flat(v, 'ar', 'full_name', fallback: false);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(widget.modern ? 22 : 8),
        border: Border.all(color: t.primaryColor.withValues(alpha: .13)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.modern ? 22 : 8),
        onTap: () => open(rows, i, kind),
        child: Padding(
          padding: EdgeInsets.all(widget.modern ? 14 : 8),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.primaryColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(widget.modern ? 15 : 8),
                ),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: t.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name(v, lang),
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.modern && ar.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          ar,
                          textDirection: TextDirection.rtl,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.textTheme.bodyLarge?.copyWith(height: 1.5),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => toggle(v, kind),
                icon: Icon(
                  saved.contains(identity(v, kind))
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: t.primaryColor,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> categoryPage(Json c, List<Json> rows) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CollectionCategoryPage(
          title: localized(c['title'], lang),
          rows: rows,
          modern: widget.modern,
        ),
      ),
    );
    if (mounted) {
      setState(
        () =>
            saved = (prefs.getStringList('collection.saved.v1') ?? []).toSet(),
      );
    }
  }

  Widget categoryCard(Json c, List<Json> rows, int i) {
    final t = Theme.of(context);
    final icons = [
      Icons.nights_stay_outlined,
      Icons.mosque,
      Icons.water_drop_outlined,
      Icons.wb_twilight,
      Icons.home_outlined,
      Icons.restaurant_outlined,
      Icons.directions_car_outlined,
      Icons.favorite_border,
      Icons.local_florist_outlined,
      Icons.public,
      Icons.volunteer_activism_outlined,
      Icons.cloud_outlined,
      Icons.spa_outlined,
      Icons.campaign_outlined,
      Icons.auto_awesome_outlined,
    ];
    return Material(
      color: t.cardColor,
      borderRadius: BorderRadius.circular(widget.modern ? 22 : 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.modern ? 22 : 8),
        onTap: () => categoryPage(c, rows),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.modern ? 22 : 8),
            border: Border.all(color: t.primaryColor.withValues(alpha: .18)),
            gradient: widget.modern
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      t.cardColor,
                      t.primaryColor.withValues(alpha: .09),
                    ],
                  )
                : null,
          ),
          child: widget.modern
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: t.primaryColor.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icons[i % icons.length],
                        color: t.primaryColor,
                        size: 21,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        localized(c['title'], lang),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${rows.length} · ${'all_duas'.tr}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.labelSmall,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(icons[i % icons.length], color: t.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(child: Text(localized(c['title'], lang))),
                    Text('${rows.length}'),
                    const Icon(Icons.chevron_right),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final q = search.text.trim().toLowerCase();
    final categories = data['dua-categories'] ?? [];
    final kinds = widget.dhikr ? ['dhikrs'] : ['masnoon-duas', 'duas'];
    final visible = <String, List<Json>>{};
    List<Json> filtered(String k) => visible.putIfAbsent(
      k,
      () => (data[k] ?? [])
          .where(
            (v) =>
                (!favorites || saved.contains(identity(v, k))) &&
                (q.isEmpty ||
                    languages.keys.any(
                      (l) => name(v, l).toLowerCase().contains(q),
                    )),
          )
          .toList(),
    );
    final browsing = q.isEmpty && !favorites;
    final total = kinds.fold<int>(0, (n, k) => n + (data[k]?.length ?? 0));
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.dhikr ? 'all_dhikr'.tr : 'all_duas'.tr,
        isBackButtonExist: widget.appBackButton,
        actions: [
          IconButton(
            tooltip: 'collection_saved'.tr,
            icon: Icon(
              favorites ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: () => setState(() => favorites = !favorites),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            controller: scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              24,
              16,
              widget.modern && !widget.appBackButton ? 120 : 24,
            ),
            children: [
              if (widget.modern && browsing)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: LinearGradient(
                      colors: [t.primaryColor, const Color(0xffA94720)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        widget.dhikr ? Images.Icon_Dikir : Images.Icon_Dua,
                        width: 42,
                        height: 42,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.dhikr ? 'all_dhikr'.tr : 'collection_masnoon'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$total · ${widget.dhikr ? 'all_dhikr'.tr : 'all_duas'.tr}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (!widget.dhikr)
                        Text(
                          '${categories.length} · ${'collection_occasions'.tr}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      if (widget.dhikr &&
                          (data['dhikrs'] ?? []).isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          name(data['dhikrs']!.first, lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => open(data['dhikrs']!, 0, 'dhikrs'),
                          icon: const Icon(Icons.menu_book_outlined),
                          label: Text('collection_recitation'.tr),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              TextField(
                controller: search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: t.cardColor,
                  hintText: 'collection_search'.tr,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(search.clear),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.modern ? 22 : 8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (favorites) heading('collection_saved'.tr),
              if (browsing) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => favorites = true),
                        icon: const Icon(Icons.bookmark_border),
                        label: Text('collection_saved'.tr),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: personal,
                        icon: const Icon(Icons.edit_note),
                        label: Text(
                          (widget.dhikr ? 'added_dhikr' : 'added_dua').tr,
                        ),
                      ),
                    ),
                  ],
                ),
                for (final k in kinds) ...[
                  for (final v in (data[k] ?? []).where(
                    (v) =>
                        identity(v, k) ==
                        prefs.getString('collection.recent.$k'),
                  ))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Material(
                        color: t.primaryColor.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(20),
                        child: ListTile(
                          leading: Icon(Icons.history, color: t.primaryColor),
                          title: Text('collection_continue'.tr),
                          subtitle: Text(name(v, lang)),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () => open(data[k]!, data[k]!.indexOf(v), k),
                        ),
                      ),
                    ),
                ],
              ],
              if (loading.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(),
                ),
              if (errors.isNotEmpty)
                TextButton.icon(
                  onPressed: refresh,
                  icon: const Icon(Icons.refresh),
                  label: Text('collection_retry'.tr),
                ),
              if (!widget.dhikr && browsing && categories.isNotEmpty) ...[
                heading(
                  'collection_occasions'.tr,
                  count: '${categories.length}',
                ),
                if (widget.modern)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 116,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemBuilder: (_, i) => categoryCard(
                      categories[i],
                      (data['masnoon-duas'] ?? [])
                          .where((v) => v['category_id'] == categories[i]['id'])
                          .toList(),
                      i,
                    ),
                  )
                else
                  for (int i = 0; i < categories.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: categoryCard(
                        categories[i],
                        (data['masnoon-duas'] ?? [])
                            .where(
                              (v) => v['category_id'] == categories[i]['id'],
                            )
                            .toList(),
                        i,
                      ),
                    ),
              ],
              for (final k in kinds) ...[
                heading(
                  (k == 'masnoon-duas'
                          ? 'collection_masnoon'
                          : k == 'duas'
                          ? 'collection_general'
                          : 'all_dhikr')
                      .tr,
                  count: '${filtered(k).length}',
                ),
                if (filtered(k).isEmpty && !loading.contains(k))
                  Text('collection_empty'.tr),
                for (int i = 0; i < filtered(k).length; i++)
                  tile(filtered(k), i, k),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CollectionCategoryPage extends StatefulWidget {
  final String title;
  final List<Json> rows;
  final bool modern;
  const CollectionCategoryPage({
    super.key,
    required this.title,
    required this.rows,
    required this.modern,
  });
  @override
  State<CollectionCategoryPage> createState() => _CollectionCategoryPageState();
}

class _CollectionCategoryPageState extends State<CollectionCategoryPage> {
  final prefs = Get.find<SharedPreferences>();
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final lang = language(Get.locale?.languageCode);
    final saved = (prefs.getStringList('collection.saved.v1') ?? []).toSet();
    return Scaffold(
      appBar: CustomAppBar(title: widget.title, isBackButtonExist: true),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            if (widget.rows.isEmpty) Text('collection_empty'.tr),
            for (int i = 0; i < widget.rows.length; i++)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.modern ? 20 : 8),
                  side: BorderSide(
                    color: t.primaryColor.withValues(alpha: .15),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(name(widget.rows[i], lang)),
                  trailing: Icon(
                    saved.contains(identity(widget.rows[i], 'masnoon-duas'))
                        ? Icons.bookmark
                        : Icons.chevron_right,
                    color: t.primaryColor,
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CollectionReader(
                          rows: widget.rows,
                          index: i,
                          kind: 'masnoon-duas',
                          modern: widget.modern,
                        ),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CollectionReader extends StatefulWidget {
  final List<Json> rows;
  final int index;
  final String kind;
  final bool modern;
  const CollectionReader({
    super.key,
    required this.rows,
    required this.index,
    required this.kind,
    required this.modern,
  });
  @override
  State<CollectionReader> createState() => _CollectionReaderState();
}

class _CollectionReaderState extends State<CollectionReader> {
  final prefs = Get.find<SharedPreferences>();
  final scroll = ScrollController();
  late int index = widget.index;
  late String lang = language(
    prefs.getString('collection.reading_language') ?? Get.locale?.languageCode,
  );
  late Set<String> saved = (prefs.getStringList('collection.saved.v1') ?? [])
      .toSet();
  Json get item => widget.rows[index];
  String get key => identity(item, widget.kind);
  @override
  void initState() {
    super.initState();
    remember();
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void remember() {
    prefs.setString('collection.recent.${widget.kind}', key);
  }

  void move(int delta) {
    setState(() => index += delta);
    remember();
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  Widget block(
    String label,
    String value, {
    bool rtl = false,
    bool arabic = false,
  }) => Card(
    elevation: 0,
    color: arabic && widget.modern
        ? Theme.of(context).primaryColor.withValues(alpha: .08)
        : Theme.of(context).cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(widget.modern ? 24 : 8),
      side: BorderSide(
        color: Theme.of(context).primaryColor.withValues(alpha: .14),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.tr,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () => Clipboard.setData(ClipboardData(text: value)),
              ),
            ],
          ),
          SelectableText(
            value,
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            textAlign: arabic ? TextAlign.center : TextAlign.start,
            style: TextStyle(fontSize: arabic ? 27 : 18, height: 1.8),
          ),
        ],
      ),
    ),
  );
  List<Widget> structured(Json content) {
    final out = <Widget>[];
    final rtl = lang == 'ar' || lang == 'ur';
    void add(String label, dynamic value) {
      final s = localized(value, lang);
      if (s.isNotEmpty) out.add(block(label, s, rtl: rtl));
    }

    add('collection_occasion', content['occasion']);
    for (final r in objects(content['recitations'])) {
      add('collection_recitation', r['label']);
      final ar = clean(r['arabic']);
      if (ar.isNotEmpty) {
        out.add(block('collection_arabic', ar, rtl: true, arabic: true));
      }
      if (lang != 'ar') add('collection_pronunciation', r['transliteration']);
      add('collection_meaning', r['meaning']);
      add('collection_repetition', object(r['repetition'])['description']);
    }
    for (final field in [
      'instructions',
      'steps',
      'virtues_and_benefits',
      'notes',
    ]) {
      for (final r in objects(content[field])) {
        add(
          field == 'virtues_and_benefits'
              ? 'collection_fazilat'
              : field == 'notes'
              ? 'collection_notes'
              : 'collection_instructions',
          r['text'],
        );
      }
    }
    for (final r in objects(content['nested_sections'])) {
      add('collection_section', r['title']);
      out.addAll(structured(r));
    }
    for (final r in objects(content['references'])) {
      final s = [
        clean(r['source_book']),
        clean(r['details']),
      ].where((v) => v.isNotEmpty).join(' · ');
      if (s.isNotEmpty) out.add(block('collection_reference', s));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final rtl = lang == 'ar' || lang == 'ur';
    final ar = flat(item, 'ar', 'full_name', fallback: false);
    final rec = flat(item, lang, 'full_name', fallback: false);
    final faz = flat(item, lang, 'fazilat', fallback: false);
    final masnoon = widget.kind == 'masnoon-duas';
    return Scaffold(
      appBar: CustomAppBar(
        title: name(item, lang),
        isBackButtonExist: true,
        actions: [
          IconButton(
            icon: Icon(
              saved.contains(key) ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (!saved.add(key)) saved.remove(key);
              });
              prefs.setStringList('collection.saved.v1', saved.toList());
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              final text = masnoon
                  ? objects(
                      object(item['content'])['recitations'],
                    ).map((r) => clean(r['arabic'])).join('\n')
                  : [ar, rec].where((s) => s.isNotEmpty).toSet().join('\n');
              SharePlus.instance.share(
                ShareParams(text: '${name(item, lang)}\n$text'),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                children: [
                  Container(
                    padding: EdgeInsets.all(widget.modern ? 20 : 8),
                    decoration: BoxDecoration(
                      color: widget.modern
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: .10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1} / ${widget.rows.length}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name(item, lang),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (index + 1) / widget.rows.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('collection_language'.tr)),
                      DropdownButton<String>(
                        value: lang,
                        items: languages.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => lang = v);
                            prefs.setString('collection.reading_language', v);
                          }
                        },
                      ),
                    ],
                  ),
                  if (masnoon)
                    ...structured(object(item['content']))
                  else ...[
                    if (ar.isNotEmpty)
                      block('collection_arabic', ar, rtl: true, arabic: true),
                    if (lang != 'ar' && rec.isNotEmpty && rec != ar)
                      block('collection_recitation', rec, rtl: rtl),
                    if (lang != 'ar' && rec.isEmpty)
                      Text('collection_missing'.tr),
                    if (faz.isNotEmpty)
                      block('collection_fazilat', faz, rtl: rtl),
                  ],
                  if (widget.kind == 'dhikrs')
                    CollectionCounter(
                      key: ValueKey(key),
                      id: item['id'].toString(),
                      modern: widget.modern,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: index == 0 ? null : () => move(-1),
                      child: Text('collection_previous'.tr),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: index == widget.rows.length - 1
                          ? null
                          : () => move(1),
                      child: Text('collection_next'.tr),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CollectionCounter extends StatefulWidget {
  final String id;
  final bool modern;
  const CollectionCounter({super.key, required this.id, required this.modern});
  @override
  State<CollectionCounter> createState() => _CollectionCounterState();
}

class _CollectionCounterState extends State<CollectionCounter> {
  final prefs = Get.find<SharedPreferences>();
  late int count = prefs.getInt(widget.id) ?? 0;
  late int target = prefs.getInt('collection.target.${widget.id}') ?? 33;
  bool busy = false;
  void change(int value) {
    if (busy) return;
    final previous = count;
    setState(() => count = value < 0 ? 0 : value);
    prefs.setInt(widget.id, count);
    if (count > previous) {
      if (target > 0 && count % target == 0) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
  }

  Future<void> reset() async {
    if (busy) return;
    setState(() => busy = true);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('collection_reset'.tr),
        content: Text('$count → 0'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('collection_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text('collection_reset'.tr),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => busy = false);
    if (ok == true) change(0);
  }

  void choose(int n) {
    setState(() => target = n);
    prefs.setInt('collection.target.${widget.id}', n);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final accent = t.primaryColor;
    final remainder = target > 0 ? count % target : 0;
    final progress = target == 0
        ? 0.0
        : count > 0 && remainder == 0
        ? 1.0
        : remainder / target;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.modern ? 28 : 8),
        side: BorderSide(color: accent.withValues(alpha: .15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'collection_count'.tr,
                    style: t.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'collection_reset'.tr,
                  onPressed: busy ? null : reset,
                  icon: const Icon(Icons.restart_alt_rounded),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                for (final n in [33, 99, 100, 0])
                  ChoiceChip(
                    label: Text(n == 0 ? '∞' : '$n'),
                    selected: target == n,
                    onSelected: (_) => choose(n),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Semantics(
              button: true,
              label: '${'collection_count'.tr}: $count',
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: busy ? null : () => change(count + 1),
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 7,
                            backgroundColor: accent.withValues(alpha: .12),
                            color: accent,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Container(
                          width: 194,
                          height: 194,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: .07),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$count',
                                style: t.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                                maxLines: 1,
                              ),
                              Text(
                                target == 0 ? '∞' : '/ $target',
                                style: t.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Icon(
                                Icons.touch_app_outlined,
                                color: accent,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (target > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('↻ ${count ~/ target}', style: t.textTheme.titleMedium),
                  Text(
                    '${count == 0
                        ? target
                        : remainder == 0
                        ? 0
                        : target - remainder} / $target',
                    style: t.textTheme.titleMedium,
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: count == 0 || busy
                        ? null
                        : () => change(count - 1),
                    child: const Icon(Icons.undo_rounded),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: busy ? null : () => change(count + 1),
                    child: const Icon(Icons.add_rounded),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
