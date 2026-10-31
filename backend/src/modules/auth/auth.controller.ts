import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Headers,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterUserDto } from './dto/register-user.dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { FirebaseAdminService } from './firebase-admin.service';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly firebaseAdmin: FirebaseAdminService,
  ) {}

  @Post('register')
  async register(
    @Headers('authorization') authHeader: string,
    @Body() dto: RegisterUserDto,
  ) {
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Authorization header with valid Firebase token is required to register.');
    }

    const token = authHeader.substring(7).trim();
    let firebaseUid: string | null = null;
    let email: string | null = null;

    if (process.env.ALLOW_MOCK_AUTH === 'true' && token.startsWith('mock-')) {
      firebaseUid = `uid-${token}`;
      email = `${token}@lumyra.health`;
    } else {
      const decoded = await this.firebaseAdmin.verifyIdToken(token);
      if (!decoded) {
        throw new UnauthorizedException('Invalid or expired Firebase ID token.');
      }
      firebaseUid = decoded.uid;
      email = decoded.email || '';
    }

    return this.authService.registerUser(firebaseUid, email || 'unspecified@lumyra.health', dto);
  }

  @Get('me')
  @UseGuards(FirebaseAuthGuard)
  async getProfile(@CurrentUser() user: AuthenticatedUser) {
    return this.authService.getMe(user);
  }
}
