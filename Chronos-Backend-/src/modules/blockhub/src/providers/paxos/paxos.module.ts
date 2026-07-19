import { Module, Global } from '@nestjs/common';
import { PaxosService } from './paxos.service';

@Global() // Available across all modules without re-importing
@Module({
  providers: [PaxosService],
  exports: [PaxosService],
})
export class PaxosModule {}
