// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/theme/text_theme.dart';

// class TradingAssistantPage extends StatelessWidget {
//   const TradingAssistantPage({super.key});

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
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 15),
//                         _buildTradingStatus(),
//                         const SizedBox(height: 24),
//                         _buildTodaysSignals(),
//                         const SizedBox(height: 24),
//                         _buildQuickAnalysis(),
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
//                   'Trading Assistant',
//                   style: TextStyles.titleMedium.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w400,
//                     fontSize: 20,
//                   ),
//                 ),
//                 Text(
//                   'AI-powered signals',
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

//   Widget _buildTradingStatus() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Trading Status',
//                 style: TextStyles.bodySmall.copyWith(
//                   color: const Color(0xFFA1A1A1),
//                   fontSize: 12,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Active',
//                 style: TextStyles.titleMedium.copyWith(
//                   color: Colors.white,
//                   fontSize: 20,
//                 ),
//               ),
//             ],
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: const Color(0x3300C950),
//               borderRadius: BorderRadius.circular(100),
//             ),
//             child: Text(
//               'Monitoring',
//               style: TextStyles.bodyMedium.copyWith(
//                 color: const Color(0xFF05DF72),
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTodaysSignals() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Today\'s Signals',
//           style: TextStyles.titleMedium.copyWith(
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//         const SizedBox(height: 12),
//         _buildSignalCard(
//           icon: Icons.trending_up,
//           iconColor: const Color(0x3300C950),
//           iconForeground: const Color(0xFF05DF72),
//           title: 'ETH Entry Signal',
//           confidence: '91% confident',
//           confidenceColor: const Color(0xFF05DF72),
//           description:
//               'Strong buying momentum detected. Optimal entry zone: \$2,280 - \$2,320',
//           entry: '\$2,300',
//           target: '\$2,580 (+12%)',
//           targetColor: const Color(0xFF05DF72),
//           stopLoss: '\$2,180 (-5%)',
//           stopLossColor: const Color(0xFFFF6467),
//           riskReward: '1:2.4',
//           riskRewardColor: const Color(0xFF05DF72),
//         ),
//         const SizedBox(height: 12),
//         _buildWarningCard(),
//       ],
//     );
//   }

//   Widget _buildSignalCard({
//     required IconData icon,
//     required Color iconColor,
//     required Color iconForeground,
//     required String title,
//     required String confidence,
//     required Color confidenceColor,
//     required String description,
//     required String entry,
//     required String target,
//     required Color targetColor,
//     required String stopLoss,
//     required Color stopLossColor,
//     required String riskReward,
//     required Color riskRewardColor,
//   }) {
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
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: iconColor,
//                   borderRadius: BorderRadius.circular(100),
//                 ),
//                 child: Icon(icon, color: iconForeground, size: 20),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           title,
//                           style: TextStyles.bodyMedium.copyWith(
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                         ),
//                         Text(
//                           confidence,
//                           style: TextStyles.bodySmall.copyWith(
//                             color: confidenceColor,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       description,
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
//                                 'Entry',
//                                 style: TextStyles.bodySmall.copyWith(
//                                   color: const Color(0xFFA1A1A1),
//                                   fontSize: 12,
//                                 ),
//                               ),
//                               Text(
//                                 entry,
//                                 style: TextStyles.bodySmall.copyWith(
//                                   color: Colors.white,
//                                   fontSize: 12,
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
//                                 'Target',
//                                 style: TextStyles.bodySmall.copyWith(
//                                   color: const Color(0xFFA1A1A1),
//                                   fontSize: 12,
//                                 ),
//                               ),
//                               Text(
//                                 target,
//                                 style: TextStyles.bodySmall.copyWith(
//                                   color: targetColor,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Stop Loss',
//                                 style: TextStyles.bodySmall.copyWith(
//                                   color: const Color(0xFFA1A1A1),
//                                   fontSize: 12,
//                                 ),
//                               ),
//                               Text(
//                                 stopLoss,
//                                 style: TextStyles.bodySmall.copyWith(
//                                   color: stopLossColor,
//                                   fontSize: 12,
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
//                                 'Risk/Reward',
//                                 style: TextStyles.bodySmall.copyWith(
//                                   color: const Color(0xFFA1A1A1),
//                                   fontSize: 12,
//                                 ),
//                               ),
//                               Text(
//                                 riskReward,
//                                 style: TextStyles.bodySmall.copyWith(
//                                   color: riskRewardColor,
//                                   fontSize: 12,
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
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // TODO: Simulate trade
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFB0B0B0),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(100),
//                     ),
//                   ),
//                   child: Text(
//                     'Simulate trade',
//                     style: TextStyles.labelMedium.copyWith(fontSize: 14),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withValues(alpha: 0.05),
//                   borderRadius: BorderRadius.circular(100),
//                 ),
//                 child: const Icon(
//                   Icons.visibility_outlined,
//                   color: Colors.white,
//                   size: 16,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWarningCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(20),
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
//                   color: const Color(0x33FB2C36),
//                   borderRadius: BorderRadius.circular(100),
//                 ),
//                 child: const Icon(
//                   Icons.warning_amber_rounded,
//                   color: Color(0xFFFF6467),
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'High volatility warning',
//                           style: TextStyles.bodyMedium.copyWith(
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                         ),
//                         Text(
//                           'High risk',
//                           style: TextStyles.bodySmall.copyWith(
//                             color: const Color(0xFFFF6467),
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'BTC volatility spike detected. Avoid new positions for 24-48 hours.',
//                       style: TextStyles.bodySmall.copyWith(
//                         color: const Color(0xFFA1A1A1),
//                         fontSize: 12,
//                       ),
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
//                 // TODO: View analysis
//               },
//               style: OutlinedButton.styleFrom(
//                 backgroundColor: Colors.white.withValues(alpha: 0.1),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 side: BorderSide(
//                   color: Colors.white.withValues(alpha: 0.5),
//                   width: 0.74,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//               ),
//               child: Text(
//                 'View analysis',
//                 style: TextStyles.labelLarge.copyWith(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickAnalysis() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Quick Analysis',
//           style: TextStyles.titleMedium.copyWith(
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: [
//             _buildAnalysisChip('BTC'),
//             _buildAnalysisChip('ETH'),
//             _buildAnalysisChip('SOL'),
//             _buildAnalysisChip('ADA'),
//             _buildAnalysisChip('DOT'),
//             _buildAnalysisChip('MATIC'),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildAnalysisChip(String symbol) {
//     return Container(
//       width: 94,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
//       ),
//       child: Column(
//         children: [
//           Text(
//             symbol,
//             style: TextStyles.bodyMedium.copyWith(
//               color: Colors.white,
//               fontSize: 12,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Analyze',
//             style: TextStyles.bodySmall.copyWith(
//               color: const Color(0xFFA1A1A1),
//               fontSize: 9,
//             ),
//           ),
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
