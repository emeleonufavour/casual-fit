import 'package:casual_fit/features/product_detail/presentation/components/grid_image_splitter.dart';
import 'package:flutter/material.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ProductDetailView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  List<int> sizes = [40, 41, 42, 43, 44, 45];

  Color _currentColor = Colors.white;

  void _updateAnimationBasedOnScroll() {
    if ((_scrollController.hasClients && _scrollController.offset > 600)) {}
    setState(() {
      _animationController.value = _scrollController.offset - 600;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(_updateAnimationBasedOnScroll);

    _animationController = AnimationController(
      duration: Duration.zero,
      vsync: this,
      lowerBound: 0,
      upperBound: 200,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _updateAnimationBasedOnScroll();
      }
    });
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
    // log("scroll offset: ${_scrollController.offset}");
    return Scaffold(
      backgroundColor: Colors.black87,
      body: NotificationListener<ScrollNotification>(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              centerTitle: false,
              floating: true,
              // snap: true,
              expandedHeight: 40.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(color: Colors.white),
              ),
            ),
            SliverToBoxAdapter(
              child: Stack(children: [
                Container(
                  height: screenHeight * 0.5,
                  width: double.maxFinite,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Image.asset(
                    "assets/p_2.png",
                    fit: BoxFit.contain,
                  ),
                ),
                // Positioned(
                //     top: 10,
                //     left: 10,
                //     child: Container(
                //       padding: const EdgeInsets.all(10),
                //       decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(2),
                //           color: Colors.black87),
                //       child: Icon(
                //         CupertinoIcons.back,
                //         color: Colors.grey.shade500,
                //       ),
                //     )),
              ]),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 25,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "手提げバッグ",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        Text(
                          "明るいカラ",
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 20),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "サイズ例",
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const Text("")
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25.0),
                      child: Row(
                        children: List.generate(5, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: index == 1
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                sizes[index].toString(),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: index == 1
                                        ? Colors.black
                                        : Colors.white),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Text(
                      "説明",
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "手提げバッグは、持ち運びに便利なアクセサリーで、日常的な使用からフォーマルな場面まで幅広く活用されます。通常はハンドルが1つまたは2つ付いており、個人の持ち物を収納するためのスペースがあります。素材やデザインは多種多様で、革、キャンバス、ナイロンなどが一般的です。",
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 20),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    GridImageSplitter(
                      imagePath: "assets/p_2_m.jpg",
                      animationValue: _animationController.value,
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        "ファッションポイント",
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "ミニバッグはカジュアルなスタイルに最適で、最小限の持ち物を携帯できます。",
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    ),
                    Text(
                      "クロスボディバッグはハンズフリーで移動したいときに便利です。",
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    ),
                    Text(
                      "レザーバッグは高級感があり、フォーマルな場面にぴったり。",
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    ),
                    Text(
                      "明るいカラーやパターンのバッグはコーディネートのアクセントとして活躍します。",
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    ),
                    const SizedBox(
                      height: 200,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
