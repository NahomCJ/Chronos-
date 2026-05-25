import {
  Controller, Get, Post, Param, Query, UseGuards, ParseUUIDPipe,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/types';
import { NftService } from './nft.service';
import { BrowseNftsDto } from './nft.dto';

@Controller('nft')
@UseGuards(JwtAuthGuard)
export class NftController {
  constructor(private readonly nftService: NftService) {}

  /** GET /nft — Browse all NFTs */
  @Get()
  browseNfts(@Query() query: BrowseNftsDto) {
    return this.nftService.browseNfts(query);
  }

  /** GET /nft/collections — List all collections */
  @Get('collections')
  getCollections(
    @Query('page') page: number,
    @Query('limit') limit: number,
  ) {
    return this.nftService.getCollections(page, limit);
  }

  /** GET /nft/collections/:id — Get single collection + its NFTs */
  @Get('collections/:id')
  getCollection(@Param('id', ParseUUIDPipe) id: string) {
    return this.nftService.getCollectionById(id);
  }

  /** GET /nft/:id — Get single NFT */
  @Get(':id')
  getNft(@Param('id', ParseUUIDPipe) id: string) {
    return this.nftService.getNftById(id);
  }

  /** GET /nft/:id/history — Ownership + transaction history */
  @Get(':id/history')
  getHistory(@Param('id', ParseUUIDPipe) id: string) {
    return this.nftService.getOwnershipHistory(id);
  }

  /** POST /nft/:id/favorite — Toggle favorite */
  @Post(':id/favorite')
  toggleFavorite(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.nftService.toggleFavorite(id, user.id);
  }
}
