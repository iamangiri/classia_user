import 'package:flutter/material.dart';

class HomeDisclaimer extends StatefulWidget {
  final String message; // <-- take message as required param

  const HomeDisclaimer({
    Key? key,
    required this.message, // <-- now required
  }) : super(key: key);

  @override
  State<HomeDisclaimer> createState() => _HomeDisclaimerState();
}

class _HomeDisclaimerState extends State<HomeDisclaimer>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25), // adjust speed here
    )..addListener(_scrollText);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.repeat();
    });
  }

  void _scrollText() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _controller.value * maxScroll;
    _scrollController.jumpTo(current);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.amber.shade100,
      alignment: Alignment.centerLeft,
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        children: [
          Center(
            child: Text(
              widget.message, // <-- use passed message
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 40), // gap before repeating
          Center(
            child: Text(
              widget.message, // <-- use passed message
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
