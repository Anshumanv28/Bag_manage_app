import 'package:flutter/material.dart';

class SopProgressHeader extends StatelessWidget {
  const SopProgressHeader({
    super.key,
    required this.steps,
    required this.activeIndex,
    this.subline,
  });

  final List<String> steps;
  final int activeIndex;
  final String? subline;

  @override
  Widget build(BuildContext context) {
    final clampedActive = activeIndex.clamp(0, (steps.isEmpty ? 0 : steps.length - 1));
    final progress = steps.length <= 1 ? 0.0 : clampedActive / (steps.length - 1);
    final cs = Theme.of(context).colorScheme;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Flow', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text(
                  '${clampedActive + 1}/${steps.isEmpty ? 1 : steps.length}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            if (subline != null) ...[
              const SizedBox(height: 4),
              Text(subline!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            _SopStepperRow(steps: steps, activeIndex: clampedActive),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SopStepperRow extends StatelessWidget {
  const _SopStepperRow({required this.steps, required this.activeIndex});

  final List<String> steps;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final n = steps.length;
    if (n == 0) return const SizedBox.shrink();

    return Row(
      children: [
        for (var i = 0; i < n; i++) ...[
          Expanded(
            child: Column(
              children: [
                _SopStepDot(
                  index: i,
                  state: i < activeIndex
                      ? _DotState.done
                      : i == activeIndex
                          ? _DotState.active
                          : _DotState.todo,
                ),
                const SizedBox(height: 6),
                Text(
                  steps[i],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          if (i != n - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < activeIndex ? cs.primary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

enum _DotState { todo, active, done }

class _SopStepDot extends StatelessWidget {
  const _SopStepDot({required this.index, required this.state});

  final int index;
  final _DotState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg = switch (state) {
      _DotState.todo => cs.surfaceContainerHighest,
      _DotState.active => cs.primary,
      _DotState.done => cs.secondaryContainer,
    };
    final fg = switch (state) {
      _DotState.todo => cs.onSurfaceVariant,
      _DotState.active => cs.onPrimary,
      _DotState.done => cs.onSecondaryContainer,
    };

    final child = switch (state) {
      _DotState.done => Icon(Icons.check, size: 18, color: fg),
      _DotState.active => Text('${index + 1}', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg)),
      _DotState.todo => Text('${index + 1}', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg)),
    };

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: state == _DotState.active
            ? [
                BoxShadow(
                  blurRadius: 10,
                  spreadRadius: 1,
                  color: cs.primary.withValues(alpha: 0.25),
                )
              ]
            : null,
      ),
      child: child,
    );
  }
}

