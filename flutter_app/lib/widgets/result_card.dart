import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/date_time_validation_service.dart';
import '../theme/app_theme.dart';

class ResultCard extends StatelessWidget {
  final DateTimeCheckResult? result;

  const ResultCard({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: isDark ? 0.75 : 0.85),
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(color: cs.line.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: result == null ? _buildEmpty(context) : _buildResult(context),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: cs.surfaceSoft,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(Icons.info_outline_rounded, color: cs.muted, size: 28),
        ),
        const SizedBox(height: 14),
        Text(
          'Chờ kiểm tra',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kết quả sẽ xuất hiện ở đây sau khi bạn nhập ngày tháng năm.',
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.muted, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = result!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
      child: Column(
        key: ValueKey('${r.valid}_${r.parts?.display ?? 'err'}_${r.errors.join()}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status header ──
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: r.valid ? cs.primarySoft : cs.dangerSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  r.valid ? Icons.check_rounded : Icons.warning_amber_rounded,
                  color: r.valid ? cs.primary : cs.danger,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KẾT QUẢ KIỂM TRA',
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      r.valid ? 'Ngày hợp lệ' : 'Ngày không hợp lệ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Message ──
          Text(
            r.valid
                ? '${r.details!.display} là một ngày hợp lệ.'
                : 'Vui lòng kiểm tra lại dữ liệu bên dưới.',
            style: TextStyle(color: cs.muted, fontSize: 14, height: 1.5),
          ),

          if (!r.valid && r.errors.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: cs.dangerSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: r.errors
                    .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: cs.danger, fontWeight: FontWeight.w700)),
                              Expanded(
                                child: Text(
                                  e,
                                  style: TextStyle(color: cs.danger, fontSize: 13, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],

          if (r.valid && r.details != null) ...[
            const SizedBox(height: 18),
            _DetailGrid(details: r.details!),
          ],
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final DateTimeDetails details;

  const _DetailGrid({required this.details});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Thứ trong tuần', details.weekday),
      ('Năm nhuận', details.leapYear),
      ('Số ngày trong tháng', details.monthDays),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final cs = Theme.of(context).colorScheme;
        return Container(
          constraints: const BoxConstraints(minWidth: 130),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceSoft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.$1.toUpperCase(),
                style: TextStyle(
                  color: cs.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.$2,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
