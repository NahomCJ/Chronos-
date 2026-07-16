import {
  Controller, Post, Get, Param, Body, UseGuards,
  UseInterceptors, UploadedFile, ParseUUIDPipe,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/types';
import { MintingService } from './minting.service';
import { MintNftDto, DeployCollectionDto } from './minting.dto';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';

const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB
const ALLOWED_MIME = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'video/mp4'];

@Controller('minting')
@UseGuards(JwtAuthGuard)
export class MintingController {
  constructor(private readonly mintingService: MintingService) {}

  /**
   * POST /minting/mint
   * Initiate an async NFT mint. Returns job ID to poll.
   */
  @Post('mint')
  @UseInterceptors(
    FileInterceptor('image', {
      limits: { fileSize: MAX_FILE_SIZE },
      fileFilter: (_req, file, cb) => {
        if (ALLOWED_MIME.includes(file.mimetype)) {
          cb(null, true);
        } else {
          cb(new Error('Unsupported file type. Allowed: JPG, PNG, GIF, WEBP, MP4'), false);
        }
      },
    }),
  )
  mintNft(
    @Body() dto: MintNftDto,
    @UploadedFile() file: Express.Multer.File,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    if (!file) throw new Error('Image file is required');
    return this.mintingService.initiateMint(user.id, dto, file);
  }

  /**
   * GET /minting/status/:jobId
   * Poll the status of a mint job.
   */
  @Get('status/:jobId')
  getMintStatus(
    @Param('jobId', ParseUUIDPipe) jobId: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.mintingService.getMintStatus(jobId, user.id);
  }

  /**
   * POST /minting/collection/create
   * Deploy a new NFT collection contract (admin/creator only).
   */
  @Post('collection/create')
  @UseGuards(RolesGuard)
  @Roles('ADMIN', 'CREATOR')
  deployCollection(
    @Body() dto: DeployCollectionDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.mintingService.deployCollection(user.id, dto);
  }
}
