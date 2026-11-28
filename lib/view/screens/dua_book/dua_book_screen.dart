// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controller/dua_book_controller.dart';
import '../../../data/model/dua_book_model.dart';
import '../../base/custom_app_bar.dart';

class DuaBookScreen extends StatefulWidget {
  final bool? appBackButton;
  final bool modern;
  const DuaBookScreen({super.key, this.appBackButton, this.modern = false});
  @override
  State<DuaBookScreen> createState() => _DuaBookScreenState();
}

class _DuaBookScreenState extends State<DuaBookScreen> {
  final c = DuaBookController();
  final scroll = ScrollController();
  final keys = <int, GlobalKey>{};
  final counts = <String, int>{};
  SharedPreferences? prefs;
  String lang = 'en';
  int page = 1;
  bool ready = false;
  static const languages = {'en':'English','hi':'हिन्दी','gu':'ગુજરાતી','ur':'اردو','ar':'العربية','sw':'Kiswahili'};
  @override
  void initState() {
    super.initState();
    lang = duaLanguage(Get.locale?.languageCode);
    scroll.addListener(track);
    load();
  }
  Future<void> load() async {
    await c.load();
    if (!mounted) return;
    prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final saved = prefs!.getString('dua_book_reader_language');
    if (languages.containsKey(saved)) lang = saved!;
    page = (prefs!.getInt('dua_book_reader_page') ?? 1).clamp(1,28).toInt();
    setState(() => ready = true);
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) jump(page); });
  }
  void track() {
    if (!ready || !mounted) return;
    final viewport = scroll.position.context.storageContext.findRenderObject();
    if (viewport is! RenderBox || !viewport.hasSize) return;
    final top = viewport.localToGlobal(Offset.zero).dy;
    int current = 1;
    for (final entry in keys.entries) {
      final box = entry.value.currentContext?.findRenderObject();
      if (box is RenderBox && box.hasSize && box.localToGlobal(Offset.zero).dy <= top + 48) current = entry.key;
    }
    if (current != page) { setState(() => page = current); prefs?.setInt('dua_book_reader_page', page); }
  }
  void jump(int p) {
    final ctx = keys[p]?.currentContext;
    if (ctx != null) Scrollable.ensureVisible(ctx, duration: Duration.zero);
  }
  @override
  void dispose() { scroll.dispose(); c.dispose(); super.dispose(); }
  List<int> pages(DuaItem i) => (i.data['source_pages'] as List).cast<int>();
  Future<void> navigate(List<DuaItem> items, {bool saved = false}) async {
    final selected = await showModalBottomSheet<int>(context: context, isScrollControlled: true, builder: (ctx) {
      String query = '';
      return StatefulBuilder(builder: (ctx, update) => SafeArea(child: SizedBox(height: MediaQuery.sizeOf(ctx).height * .72, child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search book or page'), onChanged: (v) => update(() => query = v.trim().toLowerCase()))),
        Expanded(child: ListView(children: [
          if (!saved && query.isEmpty) for (int p=1;p<=28;p++) ListTile(title: Text('Page $p'), onTap: () => Navigator.pop(ctx,p)),
          if (saved || query.isNotEmpty) for (final i in items.where((i) => (!saved || c.bookmarks.contains(i.id)) && (query.isEmpty || i.matches(query) || pages(i).any((p)=>p.toString()==query)))) ListTile(title: Text(i.title(lang).isNotEmpty ? i.title(lang) : i.text(lang), maxLines: 2, overflow: TextOverflow.ellipsis), subtitle: Text('Page ${pages(i).join('–')}'), onTap: () => Navigator.pop(ctx,pages(i).first)),
        ])),
      ]))));
    });
    if (mounted && selected != null) jump(selected);
  }
  Widget paragraph(String value, {bool arabic = false, bool heading = false}) {
    final t = Theme.of(context);
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: SelectableText(value, textDirection: arabic ? TextDirection.rtl : duaDirection(lang), textAlign: arabic || heading ? TextAlign.center : TextAlign.start, style: TextStyle(color: heading ? t.colorScheme.primary : t.colorScheme.onSurface, fontSize: arabic ? c.fontSize : heading ? 19 : 17, height: arabic ? 1.9 : 1.65, fontWeight: heading ? FontWeight.w600 : FontWeight.normal)));
  }
  Widget block(DuaItem i) {
    final title = i.title(lang);
    final repeat = i.repeat ?? 0;
    final count = counts[i.id] ?? 0;
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (pages(i).length > 1) Text('Original pages ${pages(i).join('–')}', style: Theme.of(context).textTheme.labelSmall),
      if (title.isNotEmpty) paragraph(title, heading: true),
      if (i.recitation) ...[
        if (i.arabic.isNotEmpty) paragraph(i.arabic, arabic: true),
        if (i.pronunciation(lang).isNotEmpty) paragraph(i.pronunciation(lang)),
        if (i.meaning(lang).isNotEmpty) paragraph(i.meaning(lang)),
        if (repeat > 0) Align(alignment: Alignment.center, child: OutlinedButton.icon(onPressed: () => setState(() => counts[i.id] = count >= repeat ? 0 : count+1), icon: Icon(count >= repeat ? Icons.restart_alt : Icons.add), label: Text('$count / $repeat'))),
      ] else if (i.text(lang).isNotEmpty) paragraph(i.text(lang), heading: i.type == 'subheading'),
      for (final ref in (i.data['references'] as List? ?? []).whereType<Map>()) Text('${ref['source'] ?? ''} ${ref['reference_number'] ?? ''}'.trim(), style: Theme.of(context).textTheme.bodySmall),
      Align(alignment: AlignmentDirectional.centerEnd, child: IconButton(tooltip: 'Bookmark', icon: Icon(c.bookmarks.contains(i.id) ? Icons.bookmark : Icons.bookmark_border), onPressed: () async { await c.toggle(i.id); if (mounted) setState(() {}); })),
    ]));
  }
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final items = c.book?.sections.expand((s)=>s.items).toList() ?? <DuaItem>[];
    return Scaffold(appBar: CustomAppBar(title: 'dua_book'.tr, isBackButtonExist: widget.appBackButton ?? true, actions: [
      IconButton(icon: const Icon(Icons.search), tooltip: 'Search and pages', onPressed: ready ? () => navigate(items) : null),
      IconButton(icon: const Icon(Icons.bookmarks_outlined), tooltip: 'Saved', onPressed: ready ? () => navigate(items,saved:true) : null),
    ]), body: !ready ? const Center(child: CircularProgressIndicator()) : c.error != null ? Center(child: TextButton(onPressed: () {setState(()=>ready=false); load();}, child: const Text('Retry loading book'))) : Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16,16,16,8), child: Row(children: [
        Expanded(child: TextButton(onPressed: ()=>navigate(items), child: Text('Page $page / 28'))),
        DropdownButton<String>(value: lang, items: languages.entries.map((e)=>DropdownMenuItem(value:e.key,child:Text(e.value))).toList(), onChanged:(v){if(v==null)return; final p=page; setState(()=>lang=v); prefs?.setString('dua_book_reader_language',v); WidgetsBinding.instance.addPostFrameCallback((_){if(mounted)jump(p);});}),
      ])),
      LinearProgressIndicator(value:page/28),
      Expanded(child: SingleChildScrollView(controller:scroll, padding: const EdgeInsets.fromLTRB(12,12,12,24), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth:720), child: Column(children: [
        for(int p=1;p<=28;p++) Container(key:keys.putIfAbsent(p,()=>GlobalKey()), width:double.infinity, margin:const EdgeInsets.only(bottom:12), padding:EdgeInsets.all(widget.modern?22:16), decoration:BoxDecoration(color:t.cardColor,borderRadius:BorderRadius.circular(widget.modern?18:4),border:Border.all(color:t.dividerColor)), child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          if(p==1) paragraph(c.book!.title(lang),heading:true),
          for(final i in items.where((i)=>pages(i).first==p)) block(i),
          if(!items.any((i)=>pages(i).first==p)) const Text('Content continues from the preceding original page.'),
          const Divider(), Center(child:Text('— $p —',style:t.textTheme.labelSmall)),
        ])),
      ]))))),
    ]));
  }
}
