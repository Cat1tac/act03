import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome>
    with SingleTickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  bool showBalloons = false;
  bool isPulsing = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void togglePulse() {
    if (isPulsing) {
      _pulseController.stop();
    } else {
      _pulseController.repeat(reverse: true);
    }
    setState(() => isPulsing = !isPulsing);
  }

  void triggerCelebration() {
    setState(() => showBalloons = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => showBalloons = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4EC),
      appBar: AppBar(title: const Text("Cupid's Canvas")),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),

              DropdownButton<String>(
                value: selectedEmoji,
                items: emojiOptions
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedEmoji = value ?? selectedEmoji),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: triggerCelebration,
                child: const Text('Push Me!'),
              ),

              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: togglePulse,
                child: Text(isPulsing ? 'Stop Pulse' : 'Start Pulse'),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: Center(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: CustomPaint(
                      size: const Size(300, 300),
                      painter: HeartEmojiPainter(type: selectedEmoji),
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (showBalloons) const BalloonCelebration(),
        ],
      ),
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type});
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Heart base
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10,
          center.dx + 60, center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120,
          center.dx - 110, center.dy - 10, center.dx, center.dy + 60)
      ..close();

    paint.color = type == 'Party Heart'
        ? const Color(0xFFF48FB1)
        : const Color(0xFFE91E63);
    canvas.drawPath(heartPath, paint);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
      0,
      pi,
      false,
      mouthPaint,
    );

    // Party hat
    if (type == 'Party Heart') {
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type;
}

class BalloonCelebration extends StatefulWidget {
  const BalloonCelebration({super.key});

  @override
  State<BalloonCelebration> createState() => _BalloonCelebrationState();
}

class _BalloonCelebrationState extends State<BalloonCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color randomColor() {
    const colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.orange,
      Colors.green,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          children: List.generate(18, (index) {
            final dx = random.nextDouble();
            final dy = _controller.value;

            return Positioned(
              left: MediaQuery.of(context).size.width * dx,
              bottom: MediaQuery.of(context).size.height * dy,
              child: Icon(
                Icons.circle,
                size: 50 + random.nextInt(10).toDouble(),
                color: randomColor(),
              ),
            );
          }),
        );
      },
    );
  }
}
