import { Module } from '@nestjs/common';
import { ComplianceService } from './compliance.service';
import { AuditModule } from '../audit/audit.module';

@Module({
  imports: [AuditModule],
  providers: [ComplianceService],
  exports: [ComplianceService],
})
export class ComplianceModule {}
