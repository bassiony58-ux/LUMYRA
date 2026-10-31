import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    super({
      log:
        process.env.NODE_ENV === 'development'
          ? ['query', 'info', 'warn', 'error']
          : ['warn', 'error'],
    });
  }

  async onModuleInit() {
    // Only connect eagerly if not in unit-test environment without DB
    if (process.env.SKIP_DB_CONNECT !== 'true') {
      try {
        await this.$connect();
        this.logger.log('Connected to PostgreSQL via Prisma');
      } catch (err: any) {
        this.logger.warn(`Could not connect to PostgreSQL on startup: ${err.message}. Backend will operate with mock/test modes where applicable.`);
      }
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
    this.logger.log('Disconnected from PostgreSQL');
  }
}
