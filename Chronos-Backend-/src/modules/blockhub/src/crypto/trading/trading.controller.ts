import {
  Controller,
  Post,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { TradingService } from './trading.service';
import { BuyDto } from './dto/buy.dto';
import { SellDto } from './dto/sell.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser, JwtPayload } from '../../common/decorators/current-user.decorator';

/**
 * Trading Controller
 *
 * POST /trade/buy  — buy crypto with USD
 * POST /trade/sell — sell crypto for USD
 *
 * All requests require a valid JWT.
 * User must have wallet_ready = true (enforced in ComplianceService).
 */
@Controller('trade')
@UseGuards(JwtAuthGuard)
export class TradingController {
  constructor(private readonly tradingService: TradingService) {}

  @Post('buy')
  @HttpCode(HttpStatus.OK)
  buy(@CurrentUser() user: JwtPayload, @Body() dto: BuyDto) {
    return this.tradingService.buy(user.sub, dto);
  }

  @Post('sell')
  @HttpCode(HttpStatus.OK)
  sell(@CurrentUser() user: JwtPayload, @Body() dto: SellDto) {
    return this.tradingService.sell(user.sub, dto);
  }
}
