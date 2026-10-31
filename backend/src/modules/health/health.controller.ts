import { Controller, Get } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

@Controller('health')
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  async check() {
    let dbStatus = 'disconnected';
    try {
      if (process.env.SKIP_DB_CONNECT !== 'true') {
        await this.prisma.$queryRaw`SELECT 1`;
        dbStatus = 'healthy';
      } else {
        dbStatus = 'mock-mode';
      }
    } catch {
      dbStatus = 'unhealthy';
    }

    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'lumyra-api',
      version: '1.0.0',
      database: dbStatus,
      uptimeSeconds: process.uptime(),
      environment: process.env.NODE_ENV || 'development',
    };
  }
}
