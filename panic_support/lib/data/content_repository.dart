import '../models/settings.dart';

class ContentRepository {
  const ContentRepository();

  static const List<String> reassuranceLines = [
    'This is a panic response. It feels intense, and it will pass.',
    'Your body is sounding an alarm. It will settle again.',
    'You are safe right now, even if it feels frightening.',
    'You do not have to fight this. Just keep breathing.',
    'This will ease. You can stay here as long as you need.',
    'Your body is doing its alarm pattern. It will slow down.',
  ];

  static const List<String> groundingSteps = [
    'Feel your feet on the floor. Notice the pressure.',
    'Press your palms together. Notice the contact.',
    'Look for one color nearby and name it silently.',
    'Find one object and notice its shape.',
    'Notice one sound, even a quiet one.',
    'Touch a surface and notice its temperature.',
  ];

  List<String> groundingFor(AppSettings settings) {
    final custom = settings.customGroundingStatements
        .where((statement) => statement.trim().isNotEmpty)
        .toList();
    return [...groundingSteps, ...custom];
  }
}
