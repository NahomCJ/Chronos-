import {
  Controller, Get, Post, Delete, Param, Body, Query,
  UseGuards, ParseUUIDPipe,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/types';
import { MarketplaceService } from './marketplace.service';
import { CreateListingDto, BuyNftDto, BrowseListingsDto } from './marketplace.dto';

@Controller('marketplace')
@UseGuards(JwtAuthGuard)
export class MarketplaceController {
  constructor(private readonly marketplaceService: MarketplaceService) {}

  /** GET /marketplace — Browse active listings */
  @Get()
  browseListings(@Query() query: BrowseListingsDto) {
    return this.marketplaceService.browseListings(query);
  }

  /** GET /marketplace/my/listings — User's listings */
  @Get('my/listings')
  getMyListings(@CurrentUser() user: AuthenticatedUser) {
    return this.marketplaceService.getMyListings(user.id);
  }

  /** GET /marketplace/my/purchases — User's purchase history */
  @Get('my/purchases')
  getMyPurchases(
    @CurrentUser() user: AuthenticatedUser,
    @Query('page') page: number,
    @Query('limit') limit: number,
  ) {
    return this.marketplaceService.getMyPurchases(user.id, page, limit);
  }

  /** GET /marketplace/:listingId — Single listing detail */
  @Get(':listingId')
  getListing(@Param('listingId', ParseUUIDPipe) listingId: string) {
    return this.marketplaceService.getListingById(listingId);
  }

  /** POST /marketplace/list — List an NFT for sale */
  @Post('list')
  createListing(
    @Body() dto: CreateListingDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.marketplaceService.createListing(user.id, dto);
  }

  /** POST /marketplace/buy — Purchase a listed NFT */
  @Post('buy')
  buyNft(
    @Body() dto: BuyNftDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.marketplaceService.buyNft(user.id, dto);
  }

  /** DELETE /marketplace/:listingId — Cancel a listing */
  @Delete(':listingId')
  cancelListing(
    @Param('listingId', ParseUUIDPipe) listingId: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.marketplaceService.cancelListing(user.id, listingId);
  }
}
