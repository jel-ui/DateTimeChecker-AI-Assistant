import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../services/date_time_validation_service.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/date_input_card.dart';
import '../widgets/result_card.dart';
import '../widgets/recent_history_section.dart';

class HomeScreen extends StatefulWidget {
  final HistoryService historyService;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.historyService,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _validator = DateTimeValidationService();
  final _dayCtrl = TextEditingController();
  final _monthCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  DateTimeCheckResult? _result;
  List<DateTimeParts> _history = [];
  String _liveDate = '';
  Timer? _clockTimer;

  late AnimationController _heroAnim;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) => _updateClock());
    _fillToday();

    _heroAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heroFade = CurvedAnimation(parent: _heroAnim, curve: Curves.easeOut);
    _heroSlide = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _heroAnim, curve: Curves.easeOutCubic),
    );
    _heroAnim.forward();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _dayCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    _heroAnim.dispose();
    super.dispose();
  }

  void _updateClock() {
    final now = DateTime.now();
    setState(() {
      _liveDate = DateFormat("EEEE, dd/MM/yyyy", 'vi').format(now);
    });
  }

  void _fillToday() {
    final now = DateTime.now();
    _dayCtrl.text = now.day.toString();
    _monthCtrl.text = now.month.toString();
    _yearCtrl.text = now.year.toString();
  }

  void _loadHistory() {
    setState(() {
      _history = widget.historyService.getHistory();
    });
  }

  void _onSubmit() {
    final result = _validator.validate(DateTimeCheckRequest(
      day: _dayCtrl.text,
      month: _monthCtrl.text,
      year: _yearCtrl.text,
    ));

    setState(() => _result = result);

    if (result.valid && result.parts != null) {
      widget.historyService.remember(result.parts!);
      _loadHistory();
    }
  }

  void _onClear() {
    _dayCtrl.clear();
    _monthCtrl.clear();
    _yearCtrl.clear();
    setState(() => _result = null);
  }

  void _onUseToday() {
    _fillToday();
    _onSubmit();
  }

  void _onHistoryTap(DateTimeParts parts) {
    _dayCtrl.text = parts.day.toString();
    _monthCtrl.text = parts.month.toString();
    _yearCtrl.text = parts.year.toString();
    _onSubmit();
  }

  void _onClearHistory() {
    widget.historyService.clearHistory();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.95, -1.0),
            radius: 1.8,
            colors: [
              cs.primary.withValues(alpha: 0.12),
              cs.bg,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── App Bar ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: cs.onSurface,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'CHECKER',
                                style: TextStyle(
                                  color: cs.muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _ThemeToggle(
                        isDark: isDark,
                        onTap: widget.onToggleTheme,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Hero Section ──
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _heroFade,
                  child: SlideTransition(
                    position: _heroSlide,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KIỂM TRA CHÍNH XÁC, THAO TÁC NHANH',
                            style: TextStyle(
                              color: cs.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: screenWidth > 400 ? 34 : 28,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                                letterSpacing: -1.5,
                                height: 1.05,
                              ),
                              children: [
                                const TextSpan(text: 'Ngày của bạn\n'),
                                TextSpan(
                                  text: 'có hợp lệ không?',
                                  style: TextStyle(color: cs.primary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nhập ngày, tháng, năm bất kỳ để kiểm tra và xem các thông tin hữu ích ngay lập tức.',
                            style: TextStyle(
                              color: cs.muted,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Live date card ──
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            decoration: BoxDecoration(
                              color: cs.surface.withValues(alpha: isDark ? 0.7 : 0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: cs.line),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.today_rounded, color: cs.primary, size: 20),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ngày hiện tại',
                                      style: TextStyle(
                                        color: cs.muted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _liveDate,
                                      style: TextStyle(
                                        color: cs.primary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
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

              // ── Input Card ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: DateInputCard(
                    dayController: _dayCtrl,
                    monthController: _monthCtrl,
                    yearController: _yearCtrl,
                    onSubmit: _onSubmit,
                    onClear: _onClear,
                    onUseToday: _onUseToday,
                  ),
                ),
              ),

              // ── Result Card ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                  child: ResultCard(result: _result),
                ),
              ),

              // ── Recent History ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: RecentHistorySection(
                    history: _history,
                    onTap: _onHistoryTap,
                    onClear: _onClearHistory,
                  ),
                ),
              ),

              // ── Footer ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date Checker',
                        style: TextStyle(color: cs.muted, fontSize: 12),
                      ),
                      Text(
                        'Kiểm tra ngày tháng năm',
                        style: TextStyle(color: cs.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Animated theme toggle ──
class _ThemeToggle extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeToggle({required this.isDark, required this.onTap});

  @override
  State<_ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<_ThemeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: widget.isDark ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant _ThemeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDark != oldWidget.isDark) {
      if (widget.isDark) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      identifier: 'theme_toggle_button',
      button: true,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.line),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 3.14159,
                child: Icon(
                  widget.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: cs.primary,
                  size: 20,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
