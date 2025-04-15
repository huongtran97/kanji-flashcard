import 'package:flutter/material.dart';

class JumpingDotsLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const JumpingDotsLoadingIndicator({
    super.key,
    this.color = Colors.black,
    this.size = 8.0,
  });

  @override
  // ignore: library_private_types_in_public_api
  _JumpingDotsLoadingIndicatorState createState() => _JumpingDotsLoadingIndicatorState();
}

class _JumpingDotsLoadingIndicatorState extends State<JumpingDotsLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    
    _controller3 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _animation1 = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(
        parent: _controller1,
        curve: Curves.easeInOut,
      ),
    );

    _animation2 = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(
        parent: _controller2,
        curve: Curves.easeInOut,
      ),
    );

    _animation3 = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(
        parent: _controller3,
        curve: Curves.easeInOut,
      ),
    );

    // Delay the start of the second and third animations
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _controller2.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _controller3.forward();
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation1,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -5 * _animation1.value),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
        SizedBox(width: 8),
        AnimatedBuilder(
          animation: _animation2,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -5 * _animation2.value),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
        SizedBox(width: 8),
        AnimatedBuilder(
          animation: _animation3,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -5 * _animation3.value),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}