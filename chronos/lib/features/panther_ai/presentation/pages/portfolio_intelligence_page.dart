// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/theme/text_theme.dart';
// import '../../../../core/router/route_constants.dart';

// class PortfolioIntelligencePage extends StatelessWidget {
//   const PortfolioIntelligencePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Background image
//           Positioned.fill(
//             child: Image.asset('assets/background.png', fit: BoxFit.cover),
//           ),
//           // Content
//           SafeArea(
//             child: Column(
//               children: [
//                 _buildHeader(context),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.symmetric(horizontal: 14),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 15),
//                         _buildPortfolioValue(),
//                         const SizedBox(height: 16),
//                         _buildKeyInsights(context),
//                         const SizedBox(height: 16),
//                         _buildPortfolioHealthScore(),
//                         const SizedBox(height: 16),
//                         _buildYourAssets(),
//                         const SizedBox(height: 24),
//                         _buildActionButtons(),
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
//                   'Portfolio Intelligence',
//                   style: TextStyles.titleMedium.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w400,
//                     fontSize: 20,
//                   ),
//                 ),
//                 Text(
//                   'AI health monitoring',
//                   style: TextStyles.bodySmall.copyWith(
//                     color: const Color(0xFFA1A1A1),
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPortfolioValue() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
//       ),
//       child: Column(
//         children: [
//           Text(
//             'Total Portfolio Value',
//             style: TextStyles.bodySmall.copyWith(
//               color: const Color(0xFFA1A1A1),
//               fontSize: 12,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             '\$45,890',
//             style: TextStyles.titleLarge.copyWith(
//               color: Colors.white,
//               fontSize: 36,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.arrow_upward,
//                 color: Color(0xFF05DF72),
//                 size: 16,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 '+\$5,240 (12.4%)',
//                 style: TextStyles.bodyMedium.copyWith(
//                   color: const Color(0xFF05DF72),
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             decoration: BoxDecoration(
//               border: Border(
//                 top: BorderSide(
//                   color: Colors.white.withValues(alpha: 0.1),
//                   width: 0.74,
//                 ),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'AI Status',
//                       style: TextStyles.bodySmall.copyWith(
//                         color: const Color(0xFFA1A1A1),
//                         fontSize: 12,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Stable',
//                       style: TextStyles.bodyMedium.copyWith(
//                         color: Colors.white,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0x3300C950),
//                     borderRadius: BorderRadius.circular(100),
//                   ),
//                   child: Text(
//                     'Low risk',
//                     style: TextStyles.bodySmall.copyWith(
//                       color: const Color(0xFF05DF72),
//                       fontSize: 12,
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

//   Widget _buildKeyInsights(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Key Insights',
//           style: TextStyles.titleMedium.copyWith(
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//         const SizedBox(height: 12),
//         _buildOverexposedInsight(context),
//         const SizedBox(height: 8),
//         _buildRiskConcentrationInsight(),
//         const SizedBox(height: 8),
//         _buildDiversificationInsight(),
//       ],
//     );
//   }

//   Widget _buildOverexposedInsight(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: const Color(0x33F0B100),
//                   borderRadius: BorderRadius.circular(100),
//                 ),
//                 child: const Icon(
//                   Icons.warning_amber_rounded,
//                   color: Color(0xFFF0B100),
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Overexposed to BTC',
//                       style: TextStyles.bodyMedium.copyWith(
//                         color: Colors.white,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Your portfolio is 22% overweight in Bitcoin compared to optimal allocation',
//                       style: TextStyles.bodySmall.copyWith(
//                         color: const Color(0xFFA1A1A1),
//                         fontSize: 12,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Current',
//                                 style: TextStyles.bodySmall.copyWith(
//                                   color: const Color(0xFFA1A1A1),
//                                   fontSize: 12,
//                                 ),
//                               ),
//                               Text(
//                                 '56%',
//                                 style: TextStyles.bodyMedium.copyWith(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Optimal',
//                                 style: TextStyles.bodySmall.copyWith(
//                                   color: const Color(0xFFA1A1A1),
//                                   fontSize: 12,
//                                 ),
//                               ),
//                               Text(
//                                 '34%',
//                                 style: TextStyles.bodyMedium.copyWith(
//                                   color: const Color(0xFF00D4FF),
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Difference',
//                                 style: TextStyles.bodySmall.copyWith(
//                                   color: const Color(0xFFA1A1A1),
//                                   fontSize: 12,
//                                 ),
//                               ),
//                               Text(
//                                 '+22%',
//                                 style: TextStyles.bodyMedium.copyWith(
//                                   color: const Color(0xFFFDC700),
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               onPressed: () {
//                 context.push(RouteConstants.simulateRebalance.toPath);
//               },
//               style: OutlinedButton.styleFrom(
//                 backgroundColor: Colors.white.withValues(alpha: 0.1),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 side: BorderSide(
//                   color: Colors.white.withValues(alpha: 0.5),
//                   width: 0.5,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(100),
//                 ),
//               ),
//               child: Text(
//                 'Simulate rebalance',
//                 style: TextStyles.labelMedium.copyWith(fontSize: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRiskConcentrationInsight() {
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
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: const Color(0x33FB2C36),
//               borderRadius: BorderRadius.circular(100),
//             ),
//             child: const Icon(
//               Icons.warning_amber_rounded,
//               color: Color(0xFFFF6467),
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Risk concentration',
//                   style: TextStyles.bodyMedium.copyWith(
//                     color: Colors.white,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '3 assets (BTC, ETH, SOL) contribute 71% of your total portfolio risk',
//                   style: TextStyles.bodySmall.copyWith(
//                     color: const Color(0xFFA1A1A1),
//                     fontSize: 12,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(100),
//                   child: SizedBox(
//                     height: 8,
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 48,
//                           child: Container(color: const Color(0xFF00D4FF)),
//                         ),
//                         Expanded(
//                           flex: 31,
//                           child: Container(color: const Color(0xFFB366FF)),
//                         ),
//                         Expanded(
//                           flex: 21,
//                           child: Container(color: const Color(0xFFF0B100)),
//                         ),
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

//   Widget _buildDiversificationInsight() {
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
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: const Color(0x3300C950),
//               borderRadius: BorderRadius.circular(100),
//             ),
//             child: const Icon(
//               Icons.check_circle,
//               color: Color(0xFF05DF72),
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Diversification improving',
//                   style: TextStyles.bodyMedium.copyWith(
//                     color: Colors.white,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Your recent additions to altcoins have improved portfolio diversification by 18%',
//                   style: TextStyles.bodySmall.copyWith(
//                     color: const Color(0xFFA1A1A1),
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

//   Widget _buildPortfolioHealthScore() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Portfolio Health Score',
//                     style: TextStyles.bodySmall.copyWith(
//                       color: const Color(0xFFA1A1A1),
//                       fontSize: 12,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '78/100',
//                     style: TextStyles.titleLarge.copyWith(
//                       color: Colors.white,
//                       fontSize: 30,
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 width: 64,
//                 height: 64,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: const Color(0xFFDC8F4A),
//                     width: 3.7,
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Good',
//                     style: TextStyles.bodyMedium.copyWith(
//                       color: const Color(0xFFDC8F4A),
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _buildScoreRow('Diversification', '82/100', const Color(0xFF05DF72)),
//           const SizedBox(height: 8),
//           _buildScoreRow('Risk balance', '68/100', const Color(0xFFFDC700)),
//           const SizedBox(height: 8),
//           _buildScoreRow('Performance', '85/100', const Color(0xFF05DF72)),
//         ],
//       ),
//     );
//   }

//   Widget _buildScoreRow(String label, String score, Color scoreColor) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyles.bodySmall.copyWith(
//             color: const Color(0xFFA1A1A1),
//             fontSize: 12,
//           ),
//         ),
//         Text(
//           score,
//           style: TextStyles.bodySmall.copyWith(color: scoreColor, fontSize: 12),
//         ),
//       ],
//     );
//   }

//   Widget _buildYourAssets() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Your Assets',
//           style: TextStyles.titleMedium.copyWith(
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//         const SizedBox(height: 12),
//         _buildAssetCard(
//           'Bitcoin',
//           'BTC',
//           '0.24 BTC',
//           '\$25,702',
//           '+8.2%',
//           const Color(0x33FF6900),
//           const Color(0xFFFF8904),
//           '₿',
//           const Color(0xFF05DF72),
//         ),
//         const SizedBox(height: 8),
//         _buildAssetCard(
//           'Ethereum',
//           'ETH',
//           '3.44 ETH',
//           '\$8,448',
//           '+12.7%',
//           const Color(0x33AD46FF),
//           const Color(0xFFC27AFF),
//           'Ξ',
//           const Color(0xFF05DF72),
//         ),
//         const SizedBox(height: 8),
//         _buildAssetCard(
//           'USD Coin',
//           'USDC',
//           '11,740 USDC',
//           '\$11,740',
//           '+0.0%',
//           const Color(0x332B7FFF),
//           const Color(0xFF51A2FF),
//           '\$',
//           const Color(0xFFA1A1A1),
//         ),
//       ],
//     );
//   }

//   Widget _buildAssetCard(
//     String name,
//     String symbol,
//     String amount,
//     String value,
//     String change,
//     Color bgColor,
//     Color iconColor,
//     String iconText,
//     Color changeColor,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: bgColor,
//               borderRadius: BorderRadius.circular(100),
//             ),
//             child: Center(
//               child: Text(
//                 iconText,
//                 style: TextStyle(
//                   color: iconColor,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       name,
//                       style: TextStyles.bodyMedium.copyWith(
//                         color: Colors.white,
//                         fontSize: 14,
//                       ),
//                     ),
//                     Text(
//                       value,
//                       style: TextStyles.bodyMedium.copyWith(
//                         color: Colors.white,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       amount,
//                       style: TextStyles.bodySmall.copyWith(
//                         color: const Color(0xFFA1A1A1),
//                         fontSize: 12,
//                       ),
//                     ),
//                     Text(
//                       change,
//                       style: TextStyles.bodySmall.copyWith(
//                         color: changeColor,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           const Icon(Icons.chevron_right, color: Colors.white, size: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: () {
//               // TODO: Analyze custom asset
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFB0B0B0),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 side: const BorderSide(color: Color(0x7F05DF72), width: 0.74),
//               ),
//               elevation: 0,
//             ),
//             child: Text(
//               'Analyze custom asset',
//               style: TextStyles.labelLarge.copyWith(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           width: double.infinity,
//           child: OutlinedButton(
//             onPressed: () {
//               // TODO: View trading history
//             },
//             style: OutlinedButton.styleFrom(
//               backgroundColor: Colors.white.withValues(alpha: 0.1),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               side: BorderSide(
//                 color: Colors.white.withValues(alpha: 0.5),
//                 width: 0.74,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: Text(
//               'View trading history',
//               style: TextStyles.labelLarge.copyWith(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
