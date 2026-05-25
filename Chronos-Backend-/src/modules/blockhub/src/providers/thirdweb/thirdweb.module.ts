import { Module } from '@nestjs/common';
import { ThirdwebService } from './thirdweb.service';

@Module({
  providers: [ThirdwebService],
  exports: [ThirdwebService],
})
export class ThirdwebModule {}
