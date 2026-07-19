import { Module } from '@nestjs/common';
import { NftEventGateway } from './nft-event.gateway';

@Module({
  providers: [NftEventGateway],
  exports: [NftEventGateway],
})
export class WebsocketModule {}
