import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseAdminService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseAdminService.name);
  private initialized = false;

  onModuleInit() {
    if (admin.apps.length > 0) {
      this.initialized = true;
      return;
    }

    const projectId = process.env.FIREBASE_PROJECT_ID;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

    if (projectId && clientEmail && privateKey) {
      try {
        admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            clientEmail,
            privateKey,
          }),
        });
        this.initialized = true;
        this.logger.log(`Initialized Firebase Admin SDK for project ${projectId}`);
      } catch (err: any) {
        this.logger.error(`Failed to initialize Firebase Admin SDK: ${err.message}`);
      }
    } else {
      this.logger.warn(
        'Firebase Admin credentials not fully configured. Live token verification will fail unless in ALLOW_MOCK_AUTH=true test mode.',
      );
    }
  }

  async verifyIdToken(token: string): Promise<admin.auth.DecodedIdToken | null> {
    if (!this.initialized) {
      return null;
    }
    try {
      return await admin.auth().verifyIdToken(token);
    } catch (err: any) {
      this.logger.warn(`Firebase token verification failed: ${err.message}`);
      return null;
    }
  }
}
