import 'package:flutter/material.dart';

class NextLevelButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isDisabled;

  const NextLevelButton({
    Key? key,
    required this.onPressed,
    this.label = 'Next Level',
    this.isDisabled = false,
  }) : super(key: key);

  @override
  State<NextLevelButton> createState() => _NextLevelButtonState();
}

class _NextLevelButtonState extends State<NextLevelButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
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
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 20),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(_glowAnimation.value),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                ],
                borderRadius: BorderRadius.circular(40),
              ),
              child: ElevatedButton(
                onPressed: widget.isDisabled ? null : widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  disabledBackgroundColor: Colors.grey.shade400,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
