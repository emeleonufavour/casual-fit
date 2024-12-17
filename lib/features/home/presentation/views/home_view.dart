import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(_updateAnimationBasedOnScroll);

    // Initialize animation controller with zero duration
    // so we can manually set its value
    _animationController = AnimationController(
      duration: Duration.zero,
      vsync: this,
      lowerBound: 0,
      upperBound: 200, // Adjust based on expected max scroll
    );
  }

  void _updateAnimationBasedOnScroll() {
    setState(() {
      _animationController.value = _scrollController.offset;
    });
  }

  // Calculation for horizontal and vertical translation
  double horizontalTranslation(
      bool isLeft, bool isHorizontalRow, double screenWidth) {
    return (isLeft ? -(screenWidth / 2 - 50) : (screenWidth / 2 - 50)) *
        (1 - _animationController.value / 200);
  }

  double verticalTranslation(
      bool isTop, bool isHorizontalRow, double screenHeight) {
    return isHorizontalRow
        ? (isTop ? -(screenHeight / 3 - 100) : (screenHeight / 3 - 50)) *
            (1 - _animationController.value / 200)
        : 0;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    double opacity = (_animationController.value / 200).clamp(0.0, 1.0);
    // Widget to create a container with translation
    Widget animatedContainer({
      required Color color,
      bool translateHorizontal = false,
      bool translateVertical = false,
      bool isLeft = false,
      bool isTop = false,
    }) {
      return Transform.translate(
        offset: Offset(
          translateHorizontal
              ? horizontalTranslation(isLeft, true, screenWidth)
              : 0,
          translateVertical
              ? verticalTranslation(isTop, true, screenHeight)
              : 0,
        ),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 100,
            height: 100,
            color: color,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Scroll Sync Animation')),
      body: NotificationListener<ScrollNotification>(
        child: ListView(
          controller: _scrollController,
          children: [
            ...List.generate(
                7, (index) => ListTile(title: Text('Scrollable Item $index'))),

            // Animated container that moves exactly with scroll
            Stack(
              children: [
                Column(
                  children: [
                    // 1
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        animatedContainer(
                            color: Colors.red,
                            translateHorizontal: true,
                            translateVertical: true,
                            isLeft: true,
                            isTop: true),
                        animatedContainer(
                            color: Colors.blue,
                            translateVertical: true,
                            isTop: true),
                        animatedContainer(
                            color: Colors.yellow,
                            translateHorizontal: true,
                            translateVertical: true,
                            isLeft: false,
                            isTop: true),
                      ],
                    ),
                    // 2
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        animatedContainer(
                            color: Colors.tealAccent,
                            translateHorizontal: true,
                            isLeft: true),
                        Container(
                          width: 100,
                          height: 100,
                          color: Colors.blueAccent,
                          child: const Center(
                            child:
                                Text("", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        animatedContainer(
                            color: Colors.brown,
                            translateHorizontal: true,
                            isLeft: false),
                      ],
                    ),
                    // 3
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        animatedContainer(
                            color: Colors.purple,
                            translateHorizontal: true,
                            translateVertical: true,
                            isLeft: true,
                            isTop: false),
                        animatedContainer(
                            color: Colors.green, translateVertical: true),
                        animatedContainer(
                            color: Colors.orange,
                            translateHorizontal: true,
                            translateVertical: true,
                            isLeft: false,
                            isTop: false),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // More content to scroll through
            ...List.generate(
                10, (index) => ListTile(title: Text('Scrollable Item $index'))),
          ],
        ),
      ),
    );
  }
}
