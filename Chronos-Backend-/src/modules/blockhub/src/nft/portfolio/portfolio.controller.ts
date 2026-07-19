import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/types';
import { PortfolioService } from './portfolio.service';

@Controller('portfolio')
@UseGuards(JwtAuthGuard)
export class PortfolioController {
  constructor(private readonly portfolioService: PortfolioService) {}

  /** GET /portfolio/nfts — All NFTs owned by the user */
  @Get('nfts')
  getNftHoldings(@CurrentUser() user: AuthenticatedUser) {
    return this.portfolioService.getNftHoldings(user.id);
  }

  /** GET /portfolio/summary — Portfolio summary stats */
  @Get('summary')
  getSummary(@CurrentUser() user: AuthenticatedUser) {
    return this.portfolioService.getPortfolioSummary(user.id);
  }

  /** GET /portfolio/royalties — Creator royalty earnings history */
  @Get('royalties')
  getRoyaltyHistory(
    @CurrentUser() user: AuthenticatedUser,
    @Query('page') page: number,
    @Query('limit') limit: number,
  ) {
    return this.portfolioService.getRoyaltyHistory(user.id, page, limit);
  }
}
