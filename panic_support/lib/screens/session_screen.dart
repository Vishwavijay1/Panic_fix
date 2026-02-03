import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../app.dart';
import '../data/content_repository.dart';
import '../models/panic_phase.dart';
import '../theme/panic_theme.dart';
import '../widgets/audio_control.dart';
import '../widgets/breathing_cycle.dart';
import '../widgets/elapsed_time_badge.dart';
import '../widgets/grounding_card.dart';
import '../widgets/hold_to_exit.dart';
import '../widgets/reassurance_ticker.dart';

class SessionScreen extends StatefulWidget {
  final SessionMode mode;

  const SessionScreen({super.key, required this.mode});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final _content = const ContentRepository();
  Timer? _elapsedTimer;
  Timer? _phaseTimer;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  SessionPhase _phase = SessionPhase.breathing;
  int _groundingIndex = 0;
  bool _initialized = false;

  late List<String> _groundingSteps;
  late List<String> _reassuranceLines;
  late SessionConfig _config;

  AudioPlayer? _audioPlayer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final settings = SettingsScope.of(context).settings;
    _groundingSteps = _content.groundingFor(settings);
    _reassuranceLines = ContentRepository.reassuranceLines;
    _config = SessionConfig.forMode(widget.mode, settings.earlyWarningSeconds);
    _startTimers();
    _syncAudio(settings.audioEnabled, settings.audioVolume);
    _initialized = true;
  }

  void _startTimers() {
    _startTime = DateTime.now();
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _startTime == null) return;
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    });

    _phaseTimer?.cancel();
    _phaseTimer = Timer(_config.breathingDuration, () {
      if (!mounted) return;
      setState(() => _phase = SessionPhase.grounding);
    });
  }

  Future<void> _syncAudio(bool enabled, double volume) async {
    if (enabled) {
      _audioPlayer ??= AudioPlayer();
      await _audioPlayer!.setLoopMode(LoopMode.one);
      await _audioPlayer!.setVolume(volume.clamp(0.0, 1.0));
      await _audioPlayer!.setAudioSource(
        AudioSource.asset('assets/audio/soft_tone.wav'),
      );
      await _audioPlayer!.play();
    } else {
      await _audioPlayer?.stop();
    }
  }

  Future<void> _toggleAudio() async {
    final controller = SettingsScope.of(context);
    final next = !controller.settings.audioEnabled;
    await controller.updateAudio(next);
    await _syncAudio(next, controller.settings.audioVolume);
  }

  Future<void> _updateVolume(double value) async {
    final controller = SettingsScope.of(context);
    await controller.updateAudioVolume(value);
    await _audioPlayer?.setVolume(value.clamp(0.0, 1.0));
  }

  void _nextGroundingStep() {
    if (_groundingIndex + 1 < _config.groundingCount) {
      setState(() => _groundingIndex += 1);
    } else {
      setState(() => _phase = SessionPhase.stabilize);
    }
  }

  void _returnToBreathing() {
    setState(() {
      _groundingIndex = 0;
      _phase = SessionPhase.breathing;
    });
    _phaseTimer?.cancel();
    _phaseTimer = Timer(_config.breathingDuration, () {
      if (!mounted) return;
      setState(() => _phase = SessionPhase.grounding);
    });
  }

  Future<void> _exitSession() async {
    final settings = SettingsScope.of(context).settings;
    await _audioPlayer?.stop();
    if (widget.mode == SessionMode.panic && settings.reflectionEnabled) {
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        builder: (context) => const _ReflectionSheet(),
      );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _phaseTimer?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: PanicTheme.build(),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElapsedTimeBadge(elapsed: _elapsed),
                      AudioControl(
                        enabled: SettingsScope.of(context).settings.audioEnabled,
                        volume: SettingsScope.of(context).settings.audioVolume,
                        onToggle: _toggleAudio,
                        onVolumeChanged: _updateVolume,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildPhaseContent(context)),
                  const SizedBox(height: 12),
                  ReassuranceTicker(lines: _reassuranceLines),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/crisis'),
                        child: const Text('Need urgent help?'),
                      ),
                      HoldToExitButton(onExit: _exitSession),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseContent(BuildContext context) {
    switch (_phase) {
      case SessionPhase.breathing:
        return _BreathingPhase(config: _config);
      case SessionPhase.grounding:
        final instruction = _groundingSteps.isEmpty
            ? 'Notice one thing you can feel right now.'
            : _groundingSteps[_groundingIndex % _groundingSteps.length];
        return GroundingCard(
          instruction: instruction,
          onNext: _nextGroundingStep,
          nextLabel: _groundingIndex + 1 >= _config.groundingCount
              ? 'Continue'
              : 'Next',
        );
      case SessionPhase.stabilize:
        return _StabilizePhase(onContinue: _returnToBreathing);
    }
  }
}

class SessionConfig {
  final Duration breathingDuration;
  final int groundingCount;
  final String breathingLabel;

  const SessionConfig({
    required this.breathingDuration,
    required this.groundingCount,
    required this.breathingLabel,
  });

  factory SessionConfig.forMode(SessionMode mode, int earlyWarningSeconds) {
    switch (mode) {
      case SessionMode.earlyWarning:
        return SessionConfig(
          breathingDuration: Duration(seconds: earlyWarningSeconds),
          groundingCount: 3,
          breathingLabel: 'Slow your exhale',
        );
      case SessionMode.panic:
        return const SessionConfig(
          breathingDuration: Duration(seconds: 45),
          groundingCount: 6,
          breathingLabel: 'Let the exhale be longer',
        );
    }
  }
}

class _BreathingPhase extends StatelessWidget {
  final SessionConfig config;

  const _BreathingPhase({required this.config});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context).settings;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          config.breathingLabel,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        BreathingCycle(
          inhale: Duration(seconds: settings.inhaleSeconds),
          exhale: Duration(seconds: settings.exhaleSeconds),
          pause: Duration(seconds: settings.pauseSeconds),
        ),
        const SizedBox(height: 24),
        Text(
          'Follow the shape as it gently expands and releases.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _StabilizePhase extends StatelessWidget {
  final VoidCallback onContinue;

  const _StabilizePhase({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'If it eases even a little, that is enough.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'You can stay here as long as you need.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            child: const Text('Keep grounding'),
          ),
        ),
      ],
    );
  }
}

class _ReflectionSheet extends StatefulWidget {
  const _ReflectionSheet();

  @override
  State<_ReflectionSheet> createState() => _ReflectionSheetState();
}

class _ReflectionSheetState extends State<_ReflectionSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Optional note',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Would you like to note one thing that helped? This note is not saved.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'One thing that helped…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
