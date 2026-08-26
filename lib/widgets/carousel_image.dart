// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';

// import '../../features/image_cache/presentation/widgets/custom_cached_image.dart';

// class CarouselImage extends StatelessWidget {
//   final List<String> images;
//   final Widget? child;

//   const CarouselImage({super.key, required this.images, this.child});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: Stack(
//         children: [
//           CarouselSlider.builder(
//             itemCount: images.length,
//             itemBuilder: (context, index, realIndex) {
//               return CustomCachedImage(
//                 images[index],
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorLetter: '',
//                 errorWidget: ({error, errorTitle, url}) => const Center(
//                   child: Icon(Icons.error),
//                 ),
//               );
//             },
//             options: CarouselOptions(
//               autoPlay: true,
//               autoPlayInterval: const Duration(seconds: 3),
//               autoPlayAnimationDuration: const Duration(milliseconds: 800),
//               autoPlayCurve: Curves.fastOutSlowIn,
//               viewportFraction: 1, // show 1 full image
//               aspectRatio: 3 / 4,
//               enlargeCenterPage: false,
//               enableInfiniteScroll: true,
//               pauseAutoPlayInFiniteScroll: false,
//             ),
//           ),
//           // Overlay child (e.g., tags widget)
//           if (child != null)
//             Positioned(
//               top: 12,
//               left: 12,
//               child: child!,
//             ),
//         ],
//       ),
//     );
//   }
// }
