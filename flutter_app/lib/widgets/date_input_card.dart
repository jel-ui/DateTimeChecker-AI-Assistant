import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class DateInputCard extends StatelessWidget {
  final TextEditingController dayController;
  final TextEditingController monthController;
  final TextEditingController yearController;
  final VoidCallback onSubmit;
  final VoidCallback onClear;
  final VoidCallback onUseToday;

  const DateInputCard({
    super.key,
    required this.dayController,
    required this.monthController,
    required this.yearController,
    required this.onSubmit,
    required this.onClear,
    required this.onUseToday,
  });

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NHẬP NGÀY THÁNG NĂM',
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thông tin cần kiểm tra',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    identifier: 'use_today_button',
                    button: true,
                    child: TextButton.icon(
                      onPressed: onUseToday,
                      icon: Icon(Icons.calendar_today_rounded, size: 16, color: cs.primary),
                      label: Text(
                        'Dùng hôm nay',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Inputs ──
              Text(
                'NGÀY THÁNG NĂM',
                style: TextStyle(
                  color: cs.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _DateField(
                      controller: dayController,
                      identifier: 'day_input',
                      label: 'Ngày',
                      hint: 'DD',
                      nextFocus: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: _DateField(
                      controller: monthController,
                      identifier: 'month_input',
                      label: 'Tháng',
                      hint: 'MM',
                      nextFocus: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: _DateField(
                      controller: yearController,
                      identifier: 'year_input',
                      label: 'Năm',
                      hint: 'YYYY',
                      nextFocus: false,
                      onSubmit: onSubmit,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Buttons ──
              Row(
                children: [
                  Expanded(
                    child: _AnimatedPrimaryButton(
                      identifier: 'check_now_button',
                      onPressed: onSubmit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_rounded, size: 20),
                          const SizedBox(width: 8),
                          const Text('Kiểm tra ngay'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Semantics(
                    identifier: 'clear_data_button',
                    button: true,
                    child: TextButton(
                      onPressed: onClear,
                      child: Text(
                        'Xóa dữ liệu',
                        style: TextStyle(color: cs.muted, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single date input field ──
class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final String identifier;
  final String label;
  final String hint;
  final bool nextFocus;
  final VoidCallback? onSubmit;

  const _DateField({
    required this.controller,
    required this.identifier,
    required this.label,
    required this.hint,
    required this.nextFocus,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Semantics(
          identifier: identifier,
          textField: true,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textInputAction: nextFocus ? TextInputAction.next : TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d-]')),
            ],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(hintText: hint),
            onFieldSubmitted: (_) {
              if (onSubmit != null) onSubmit!();
            },
          ),
        ),
      ],
    );
  }
}

// ── Animated primary button with scale effect ──
class _AnimatedPrimaryButton extends StatefulWidget {
  final String identifier;
  final VoidCallback onPressed;
  final Widget child;

  const _AnimatedPrimaryButton({
    required this.identifier,
    required this.onPressed,
    required this.child,
  });

  @override
  State<_AnimatedPrimaryButton> createState() => _AnimatedPrimaryButtonState();
}

class _AnimatedPrimaryButtonState extends State<_AnimatedPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: widget.identifier,
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          HapticFeedback.mediumImpact();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: child,
          ),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
              child: IconTheme(
                data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
                child: Center(child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
