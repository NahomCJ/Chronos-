import {
  Controller,
  Get,
  Param,
  Query,
  UseGuards,
  ParseIntPipe,
  DefaultValuePipe,
  NotFoundException,
} from '@nestjs/common';
import { PortfolioService } from './portfolio.service';
import { MarketDataService } from './market-data.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser, JwtPayload } from '../../common/decorators/current-user.decorator';

// Market prices is intentionally public — no JWT required
// All other routes on this controller require JWT
@Controller()
export class PortfolioController {
  constructor(
    private readonly portfolioService: PortfolioService,
    private readonly marketData: MarketDataService,
  ) {}

  /**
   * GET /portfolio
   * Returns holdings + live PnL for the authenticated user.
   */
  @Get('portfolio')
  @UseGuards(JwtAuthGuard)
  getPortfolio(@CurrentUser() user: JwtPayload) {
    return this.portfolioService.getPortfolio(user.sub);
  }

  /**
   * GET /transactions
   * Paginated + filterable trade history.
   */
  @Get('transactions')
  @UseGuards(JwtAuthGuard)
  getTransactions(
    @CurrentUser() user: JwtPayload,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(25), ParseIntPipe) limit: number,
    @Query('asset') asset?: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.portfolioService.getTransactions(
      user.sub,
      page,
      Math.min(limit, 100), // cap at 100 per page
      undefined,
      asset,
      from ? new Date(from) : undefined,
      to ? new Date(to) : undefined,
    );
  }

  /**
   * GET /market/prices
   * Current prices for all supported assets.
   * Public endpoint — no JWT required.
   */
  @Get('market/prices')
  getMarketPrices() {
    return this.marketData.getPriceSnapshot();
  }

  /**
   * GET /market/prices/:asset
   * Current price for a single asset (e.g. BTC, ETH, SOL, UNI, AAVE, LINK).
   * Public endpoint — no JWT required.
   */
  @Get('market/prices/:asset')
  async getAssetPrice(@Param('asset') asset: string) {
    try {
      const price = await this.marketData.getPrice(asset.toUpperCase());
      return {
        asset: asset.toUpperCase(),
        price,
        updated_at: new Date().toISOString(),
      };
    } catch {
      throw new NotFoundException(`Asset ${asset.toUpperCase()} is not supported`);
    }
  }
}
