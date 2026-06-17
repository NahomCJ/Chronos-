// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/theme/text_theme.dart';
// import '../../../../core/router/route_constants.dart';

// class EthereumDetailPage extends StatefulWidget {
//   const EthereumDetailPage({super.key});

//   @override
//   State<EthereumDetailPage> createState() => _EthereumDetailPageState();
// }

// class _EthereumDetailPageState extends State<EthereumDetailPage> {
//   String selectedTimeframe = '1D';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Background image
//           Positioned.fill(
//             child: Stack(fit: StackFit.expand, children: [CachedNetworkImage(imageUrl: 'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, placeholder: (_, __) => Container(color: const Color(0xFF0A1628)), errorWidget: (_, __, ___) => Container(color: const Color(0xFF0A1628))), Container(color: Colors.black.withValues(alpha: 0.58))]),
//           ),
//           // Content
//           SafeArea(
//             child: Column(
//               children: [
//                 _buildHeader(context),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 15),
//                         _buildPriceCard(),
//                         const SizedBox(height: 24),
//                         _buildYourHoldings(),
//                         const SizedBox(height: 24),
//                         _buildMarketStatistics(),
//                         const SizedBox(height: 24),
//                         _buildAIAnalysis(),
//                         const SizedBox(height: 24),
//                         _buildActionButtons(),
//                         const SizedBox(height: 18),
//                         _buildViewAllPayments(),
//                         const SizedBox(height: 100),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: () => context.pop(),
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Ethereum',
//                   style: TextStyles.titleMedium.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w400,
//                     fontSize: 20,
//                   ),
//                 ),
//                 Text(
//                   'ETH',
//                   style: TextStyles.bodySmall.copyWith(
//                     color: const Color(0xFFA1A1A1),
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: 0.05),
//               borderRadius: BorderRadius.circular(100),
//             ),
//             child: Text(
//               selectedTimeframe,
//               style: TextStyles.bodyMedium.copyWith(
//                 color: Colors.white,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPriceCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '\$2,456',
//             style: TextStyles.titleLarge.copyWith(
//               color: Colors.white,
//               fontSize: 30,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               const Icon(
//                 Icons.arrow_upward,
//                 color: Color(0xFF05DF72),
//                 size: 16,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 '+3.2%',
//                 style: TextStyles.bodyMedium.copyWith(
//                   color: const Color(0xFF05DF72),
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 '(+\$76)',
//                 style: TextStyles.bodySmall.copyWith(
//                   color: const Color(0xFFA1A1A1),
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           // Chart placeholder
//           Container(
//             height: 96,
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: 0.02),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Center(
//               child: Text(
//                 'Chart',
//                 style: TextStyles.bodySmall.copyWith(
//                   color: const Color(0xFFA1A1A1),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildYourHoldings() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Your Holdings',
//           style: TextStyles.titleMedium.copyWith(
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(child: _buildHoldingCard('Amount', '3.44 ETH')),
//             const SizedBox(width: 8),
//             Expanded(child: _buildHoldingCard('Value', '\$8,450')),
//             const SizedBox(width: 8),
//             Expanded(
//               child: _buildHoldingCard(
//                 'Allocation',
//                 '35%',
//                 valueColor: const Color(0xFFDC8F4A),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildHoldingCard(String label, String value, {Color? valueColor}) {
//     return Container(
//       padding: const EdgeInsets.all(13),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: TextStyles.bodySmall.copyWith(
//               color: const Color(0xFFA1A1A1),
//               fontSize: 9,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             textAlign: TextAlign.center,
//             style: TextStyles.bodyMedium.copyWith(
//               color: valueColor ?? Colors.white,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMarketStatistics() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Market Statistics',
//           style: TextStyles.titleMedium.copyWith(
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white.withValues(alpha: 0.05),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
//           ),
//           child: Column(
//             children: [
//               _buildStatRow('24h High', '\$2,498'),
//               const SizedBox(height: 12),
//               _buildStatRow('24h Low', '\$2,368'),
//               const SizedBox(height: 12),
//               _buildStatRow('24h Volume', '\$14.2B'),
//               const SizedBox(height: 12),
//               _buildStatRow('Market Cap', '\$295B'),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyles.bodyMedium.copyWith(
//             color: const Color(0xFFA1A1A1),
//             fontSize: 14,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyles.bodyMedium.copyWith(
//             color: Colors.white,
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAIAnalysis() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'AI Analysis',
//           style: TextStyles.titleMedium.copyWith(
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//         const SizedBox(height: 12),
//         _buildAnalysisCard(
//           'Positive momentum with increasing trading volume',
//           '88% confidence',
//           const Color(0xFF05DF72),
//         ),
//         const SizedBox(height: 12),
//         _buildAnalysisCard(
//           'High correlation with BTC price movement',
//           '85% confidence',
//           const Color(0xFFDC8F4A),
//         ),
//       ],
//     );
//   }

//   Widget _buildAnalysisCard(
//     String description,
//     String confidence,
//     Color confidenceColor,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(Icons.auto_awesome, color: Color(0xFFDC8F4A), size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   description,
//                   style: TextStyles.bodyMedium.copyWith(
//                     color: const Color(0xFFA1A1A1),
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   confidence,
//                   style: TextStyles.bodySmall.copyWith(
//                     color: confidenceColor,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () {
//               // TODO: Buy action
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0x7F00A63E),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(11),
//                 side: const BorderSide(color: Color(0x7F05DF72), width: 0.61),
//               ),
//               elevation: 0,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.arrow_upward, size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Buy',
//                   style: TextStyles.labelLarge.copyWith(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w400,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () {
//               // TODO: Sell action
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0x7FE7000B),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(11),
//                 side: const BorderSide(color: Color(0x7FFF6366), width: 0.61),
//               ),
//               elevation: 0,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.arrow_downward, size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Sell',
//                   style: TextStyles.labelLarge.copyWith(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w400,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildViewAllPayments() {
//     return SizedBox(
//       width: double.infinity,
//       child: OutlinedButton(
//         onPressed: () {
//           context.push(RouteConstants.portfolioIntelligence.toPath);
//         },
//         style: OutlinedButton.styleFrom(
//           backgroundColor: Colors.white.withValues(alpha: 0.1),
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           side: const BorderSide(color: Color(0xFFDC8F4A), width: 0.74),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//         child: Text(
//           'View all payments',
//           style: TextStyles.labelLarge.copyWith(
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
