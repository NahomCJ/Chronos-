import {
  Controller, Get, Post, Param, Query, UseGuards, ParseUUIDPipe,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/types';
import { NftService } from './nft.service';
import { BrowseNftsDto, CollectionsQueryDto, TopVolumeQueryDto } from './nft.dto';

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

  // NOTE: these static "collections/*" routes must stay ABOVE
  // "collections/:id" below — Nest matches routes in declaration order,
  // so "featured"/"trending"/"top-volume" would otherwise be captured by
  // ParseUUIDPipe on :id and 400.

  /** GET /nft/collections/featured — admin-curated collection, or the highest-volume one if none is marked */
  @Get('collections/featured')
  getFeaturedCollection() {
    return this.nftService.getFeaturedCollection();
  }

  /** GET /nft/collections/trending — collections ranked by 24h volume */
  @Get('collections/trending')
  getTrendingCollections(@Query() query: CollectionsQueryDto) {
    return this.nftService.getTrendingCollections(query.category, query.limit);
  }

  /** GET /nft/collections/top-volume — collections ranked by volume over a selectable period */
  @Get('collections/top-volume')
  getTopVolumeCollections(@Query() query: TopVolumeQueryDto) {
    return this.nftService.getTopVolumeCollections(query.period, query.category, query.limit);
  }

  /** GET /nft/drops/new — most recently minted NFTs, optionally filtered by collection category */
  @Get('drops/new')
  getNewDrops(@Query() query: CollectionsQueryDto) {
    return this.nftService.getNewDrops(query.category, query.limit);
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
