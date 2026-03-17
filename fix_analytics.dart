import 'dart:io';

void main() {
  final file = File(r'c:\Users\GOLDEN\Desktop\peckpapers\lib\features\analytics\analytics_screen.dart');
  var content = file.readAsStringSync();
  
  // Replace imports and models
  final regExpMockData = RegExp(r'class _DayActivity \{.*?\nfinal _heatmap = List\.generate\(35, \(i\) => math\.Random\(i \* 7\)\.nextInt\(5\)\);', dotAll: true);
  if (regExpMockData.hasMatch(content)) {
    content = content.replaceFirst(regExpMockData, "import '../../core/services/analytics_service.dart';");
  } else {
    print("Could not find mock data to replace. Try running grep or checking the file.");
  }

  // State variables for analytics screen
  content = content.replaceFirst(
    '  late Animation<double> _chartAnim;', 
    '''  late Animation<double> _chartAnim;
  
  AnalyticsData? _data;
  
  Future<void> _loadData() async {
    final d = await AnalyticsService.instance.getData();
    if (!mounted) return;
    setState(() => _data = d);
  }'''
  );

  // Update initState
  content = content.replaceFirst(
    '''    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _chartCtrl.forward();
    });
  }''',
    '''    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _chartCtrl.forward();
    });
    _loadData();
  }'''
  );

  // Update _TopStatsRow call
  content = content.replaceFirst(
    'child: _TopStatsRow(),',
    'child: _data == null ? const SizedBox() : _TopStatsRow(data: _data!),'
  );

  // Update _ActivityChartCard call
  content = content.replaceFirst(
    'child: _ActivityChartCard(anim: _chartAnim),',
    'child: _data == null ? const SizedBox() : _ActivityChartCard(anim: _chartAnim, data: _data!),'
  );

  // Update _StreakTimeRow call
  content = content.replaceFirst(
    'child: _StreakTimeRow(anim: _chartAnim),',
    'child: _data == null ? const SizedBox() : _StreakTimeRow(anim: _chartAnim, data: _data!),'
  );

  // Update _SubjectMasteryRow generation
  content = content.replaceFirst(
    '''          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                child: _SubjectMasteryRow(
                  subject: _subjects[i],
                  anim: _chartAnim,
                  rank: i,
                ),
              ),
              childCount: _subjects.length,
            ),
          ),''',
    '''          if (_data != null)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                  child: _SubjectMasteryRow(
                    subject: _data!.subjects[i],
                    anim: _chartAnim,
                    rank: i,
                  ),
                ),
                childCount: _data!.subjects.length,
              ),
            ),'''
  );

  // Update _HeatmapCard call
  content = content.replaceFirst(
    'child: _HeatmapCard(data: _heatmap),',
    'child: _data == null ? const SizedBox() : _HeatmapCard(data: _data!.heatmap),'
  );

  // Update _WorldRankCard call
  content = content.replaceFirst(
    'child: _WorldRankCard(anim: _chartAnim),',
    'child: _data == null ? const SizedBox() : _WorldRankCard(anim: _chartAnim, data: _data!),'
  );

  // Widget updates: _TopStatsRow
  content = content.replaceFirst(
    'class _TopStatsRow extends StatelessWidget {',
    'class _TopStatsRow extends StatelessWidget {\n  const _TopStatsRow({required this.data});\n  final AnalyticsData data;'
  );
  content = content.replaceFirst(
    "value: '4h 20m',",
    "value: '\${data.studyTimeMinutes ~/ 60}h \${data.studyTimeMinutes % 60}m',"
  );
  content = content.replaceFirst(
    "value: '186',",
    "value: '\${data.worldRank}',"
  );

  // Widget updates: _ActivityChartCard 
  content = content.replaceFirst(
    'class _ActivityChartCard extends StatelessWidget {\n  const _ActivityChartCard({required this.anim});\n  final Animation<double> anim;',
    'class _ActivityChartCard extends StatelessWidget {\n  const _ActivityChartCard({required this.anim, required this.data});\n  final Animation<double> anim;\n  final AnalyticsData data;'
  );
  content = content.replaceFirst(
    "Text('30h 50m this week', style: AppTextStyles.bodyMD),",
    "Text('\${data.studyTimeMinutes ~/ 60}h \${data.studyTimeMinutes % 60}m this week', style: AppTextStyles.bodyMD),"
  );
  content = content.replaceFirst(
    'data: _weekActivity,',
    'data: data.weekActivity,'
  );
  content = content.replaceFirst(
    'children: _weekActivity',
    'children: data.weekActivity'
  );

  // Widget updates: _StreakTimeRow
  content = content.replaceFirst(
    'class _StreakTimeRow extends StatelessWidget {\n  const _StreakTimeRow({required this.anim});\n  final Animation<double> anim;',
    'class _StreakTimeRow extends StatelessWidget {\n  const _StreakTimeRow({required this.anim, required this.data});\n  final Animation<double> anim;\n  final AnalyticsData data;'
  );

  // Widget updates: _SubjectMasteryRow 
  content = content.replaceFirst(
    'final _SubjectMastery subject;',
    'final SubjectMastery subject;'
  );
  content = content.replaceFirst(
    'Icon(Icons.science_rounded, color: subject.color, size: 24),',
    'Icon(Icons.science_rounded, color: Color(subject.colorValue), size: 24),' // Fallback icon 
  );
  content = content.replaceFirst(
    'backgroundColor: subject.color.withOpacityCompat(0.15),',
    'backgroundColor: Color(subject.colorValue).withOpacityCompat(0.15),'
  );
  content = content.replaceFirst(
    'color: subject.color,',
    'color: Color(subject.colorValue),' // for indicator value color
  );
  
  // Widget updates: _WorldRankCard
  content = content.replaceFirst(
    'class _WorldRankCard extends StatelessWidget {\n  const _WorldRankCard({required this.anim});\n  final Animation<double> anim;',
    'class _WorldRankCard extends StatelessWidget {\n  const _WorldRankCard({required this.anim, required this.data});\n  final Animation<double> anim;\n  final AnalyticsData data;'
  );

  file.writeAsStringSync(content);
  print('Done applying changes to analytics_screen.dart');
}
