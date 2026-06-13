import "dart:async";

import "package:flutter/material.dart";

import "../../records/widgets/month_calendar.dart";

class StreakCalendarStamp extends StatefulWidget {
  const StreakCalendarStamp({
    super.key,
    required this.year,
    required this.month,
    required this.workoutDates,
    required this.stampDate,
  });

  final int year;
  final int month;
  final Set<DateTime> workoutDates;
  final DateTime stampDate;

  @override
  State<StreakCalendarStamp> createState() => _StreakCalendarStampState();
}

class _StreakCalendarStampState extends State<StreakCalendarStamp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetY;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;
  late final Animation<double> _inkOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _offsetY = Tween<double>(begin: -40, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.55, curve: Curves.easeInCubic),
      ),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.45, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_controller);
    _rotation = Tween<double>(begin: -0.22, end: -0.07).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _inkOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.82, curve: Curves.easeOut),
      ),
    );

    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 380), () {
        if (mounted) _controller.forward();
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _hasWorkout(DateTime date) {
    return widget.workoutDates.any(
      (workoutDate) => MonthCalendar.isSameDay(workoutDate, date),
    );
  }

  bool _isStampDay(DateTime date) {
    return MonthCalendar.isSameDay(date, widget.stampDate);
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(widget.year, widget.month, 1);
    final daysInMonth = DateTime(widget.year, widget.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "${widget.year}年${widget.month}月",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Expanded(child: Center(child: Text("日"))),
                Expanded(child: Center(child: Text("月"))),
                Expanded(child: Center(child: Text("火"))),
                Expanded(child: Center(child: Text("水"))),
                Expanded(child: Center(child: Text("木"))),
                Expanded(child: Center(child: Text("金"))),
                Expanded(child: Center(child: Text("土"))),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: ((daysInMonth + startWeekday + 6) ~/ 7) * 7,
              itemBuilder: (context, index) {
                final day = index - startWeekday + 1;
                if (day < 1 || day > daysInMonth) {
                  return const SizedBox.shrink();
                }

                final date = DateTime(widget.year, widget.month, day);
                final isStampDay = _isStampDay(date);
                final hasWorkout = _hasWorkout(date) && !isStampDay;

                return _CalendarDayCell(
                  day: day,
                  isStampDay: isStampDay,
                  hasWorkout: hasWorkout,
                  colorScheme: colorScheme,
                  stampAnimation: isStampDay ? _controller : null,
                  offsetY: isStampDay ? _offsetY : null,
                  scale: isStampDay ? _scale : null,
                  rotation: isStampDay ? _rotation : null,
                  inkOpacity: isStampDay ? _inkOpacity : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.isStampDay,
    required this.hasWorkout,
    required this.colorScheme,
    this.stampAnimation,
    this.offsetY,
    this.scale,
    this.rotation,
    this.inkOpacity,
  });

  final int day;
  final bool isStampDay;
  final bool hasWorkout;
  final ColorScheme colorScheme;
  final AnimationController? stampAnimation;
  final Animation<double>? offsetY;
  final Animation<double>? scale;
  final Animation<double>? rotation;
  final Animation<double>? inkOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isStampDay
            ? colorScheme.primaryContainer.withValues(alpha: 0.35)
            : hasWorkout
                ? colorScheme.primaryContainer.withValues(alpha: 0.2)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isStampDay
            ? Border.all(
                color: colorScheme.primary.withValues(alpha: 0.45),
                width: 1.5,
              )
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Text(
            "$day",
            style: TextStyle(
              fontWeight: isStampDay || hasWorkout
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isStampDay
                  ? colorScheme.primary
                  : colorScheme.onSurface,
            ),
          ),
          if (hasWorkout)
            Positioned(
              bottom: 2,
              child: HankoMark(size: 20),
            ),
          if (isStampDay &&
              stampAnimation != null &&
              offsetY != null &&
              scale != null &&
              rotation != null &&
              inkOpacity != null)
            AnimatedBuilder(
              animation: stampAnimation!,
              builder: (context, child) {
                final landed = stampAnimation!.value >= 0.5;
                return Transform.translate(
                  offset: Offset(0, landed ? 0 : offsetY!.value),
                  child: Transform.scale(
                    scale: scale!.value,
                    child: Transform.rotate(
                      angle: rotation!.value,
                      child: Opacity(
                        opacity: landed ? inkOpacity!.value : 1,
                        child: HankoMark(size: landed ? 24 : 30),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class HankoMark extends StatelessWidget {
  const HankoMark({super.key, required this.size});

  final double size;

  static const _stampColor = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _stampColor, width: size * 0.07),
      ),
      alignment: Alignment.center,
      child: Text(
        "済",
        style: TextStyle(
          color: _stampColor.withValues(alpha: 0.88),
          fontSize: size * 0.42,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}
