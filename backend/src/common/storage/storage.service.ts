import { Injectable, Logger } from '@nestjs/common';
import * as crypto from 'crypto';

export interface SignedUrlResult {
  url: string;
  expiresAt: Date;
  storageKey: string;
}

@Injectable()
export class StorageService {
  private readonly logger = new Logger(StorageService.name);
  private readonly bucketName = process.env.STORAGE_BUCKET_NAME || 'lumyra-medical-vault-private';
  private readonly signedUrlExpirySeconds = parseInt(
    process.env.SIGNED_URL_EXPIRY_SECONDS || '900',
    10,
  ); // 15 minutes default

  /**
   * Generates a secure, short-lived signed URL for downloading / viewing a medical scan or document.
   * NEVER generates a public URL.
   */
  async getReadSignedUrl(storageKey: string, expirySeconds?: number): Promise<SignedUrlResult> {
    const ttl = expirySeconds || this.signedUrlExpirySeconds;
    const expiresAt = new Date(Date.now() + ttl * 1000);
    
    // In production with S3/GCS:
    // const command = new GetObjectCommand({ Bucket: this.bucketName, Key: storageKey });
    // const url = await getSignedUrl(s3Client, command, { expiresIn: ttl });
    
    // Abstracted secure signed URL generator:
    const token = crypto
      .createHmac('sha256', process.env.STORAGE_SIGNING_SECRET || 'lumyra-vault-secret-key-do-not-leak')
      .update(`${storageKey}:${expiresAt.getTime()}`)
      .digest('hex');

    const baseUrl = process.env.STORAGE_ENDPOINT_URL || 'https://storage-vault.internal.lumyra.app';
    const url = `${baseUrl}/${this.bucketName}/${storageKey}?expires=${expiresAt.getTime()}&sig=${token}`;

    return {
      url,
      expiresAt,
      storageKey,
    };
  }

  /**
   * Generates a pre-signed PUT URL for direct-to-storage medical uploads.
   * Prevents raw binary payloads from traversing the application server.
   */
  async getUploadSignedUrl(
    patientId: string,
    filename: string,
    mimeType: string,
  ): Promise<{ uploadUrl: string; storageKey: string; expiresAt: Date }> {
    const uniqueId = crypto.randomUUID();
    const sanitizedFilename = filename.replace(/[^a-zA-Z0-9.-]/g, '_');
    const storageKey = `patients/${patientId}/scans/${uniqueId}-${sanitizedFilename}`;
    
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 mins
    const token = crypto
      .createHmac('sha256', process.env.STORAGE_SIGNING_SECRET || 'lumyra-vault-secret-key-do-not-leak')
      .update(`upload:${storageKey}:${expiresAt.getTime()}`)
      .digest('hex');

    const baseUrl = process.env.STORAGE_ENDPOINT_URL || 'https://storage-vault.internal.lumyra.app';
    const uploadUrl = `${baseUrl}/${this.bucketName}/${storageKey}?action=put&expires=${expiresAt.getTime()}&sig=${token}&content_type=${encodeURIComponent(mimeType)}`;

    this.logger.log(`Issued secure upload grant for patient ${patientId}, key: ${storageKey}`);

    return {
      uploadUrl,
      storageKey,
      expiresAt,
    };
  }
}
