import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OfferCarousel extends StatefulWidget {
  const OfferCarousel({super.key});

  @override
  _OfferCarouselState createState() => _OfferCarouselState();
}

class _OfferCarouselState extends State<OfferCarousel> {
  final List<String> carouselImages = [
    'assets/slider1.svg',
    'assets/slider2.svg',
    'assets/slider3.svg',
  ];

  int _currentPage = 0;
  late PageController _pageController;

  void _autoSlide() {
    if (!_pageController.hasClients) return;

    // Si el índice llega al último, vuelve al principio
    int nextPage = (_currentPage + 1) % carouselImages.length;

    // Hacemos la transición al siguiente índice
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    // Actualizamos el estado del índice actual
    setState(() {
      _currentPage = nextPage;
    });

    // Después de 5 segundos, vuelve a llamar a esta función
    Future.delayed(const Duration(seconds: 5), _autoSlide);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Iniciamos la llamada automática de la función
    Future.delayed(const Duration(seconds: 5), _autoSlide);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título de la sección
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ofertas especiales',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Ver todo',
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            ],
          ),
        ),

        // Carrusel de imágenes
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: carouselImages.length,
            itemBuilder: (context, index) {
              return SvgPicture.asset(carouselImages[index], fit: BoxFit.cover);
            },
            onPageChanged: (index) => setState(() => _currentPage = index),
          ),
        ),

        // Indicadores del carrusel
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(carouselImages.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
              width: _currentPage == index ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.red.shade900
                    : Colors.red.shade300,
                borderRadius: BorderRadius.circular(5),
              ),
            );
          }),
        ),
      ],
    );
  }
}
