import { Module } from '@nestjs/common';
import { ComplianceService } from './compliance.service';

/**
 * ComplianceModule
 *
 * No TypeORM feature registration needed here — ComplianceService
 * uses the shared DataSource (injected globally by TypeOrmModule.forRoot)
 * to run raw queries against the user_compliance view.
 */
@Module({
  providers: [ComplianceService],
  exports: [ComplianceService],
})
export class ComplianceModule {}
