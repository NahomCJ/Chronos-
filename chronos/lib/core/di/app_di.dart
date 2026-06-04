import 'package:get_it/get_it.dart';

import '../../features/auth/di/auth_di.dart';
import '../../features/home/di/home_di.dart';
import '../../features/wallet/di/wallet_di.dart';
import '../../features/transfer/di/transfer_di.dart';
import '../../features/exchange/di/exchange_di.dart';
import '../../features/panther_ai/di/panther_ai_di.dart';
import '../../features/blockhub/di/blockhub_di.dart';
import '../../features/tickpay/di/tickpay_di.dart';
import '../../features/profile/di/profile_di.dart';

final GetIt sl = GetIt.instance;

Future<void> initAppDi() async {
  await initAuthDi(sl);
  initHomeDi(sl);
  initWalletDi(sl);
  initTransferDi(sl);
  initExchangeDi(sl);
  initPantherAiDi(sl);
  initBlockhubDi(sl);
  initTickpayDi(sl);
  initProfileDi(sl);
}
