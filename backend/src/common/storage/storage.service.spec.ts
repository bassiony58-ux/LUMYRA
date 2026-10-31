import { StorageService } from './storage.service';

describe('StorageService', () => {
  let service: StorageService;

  beforeEach(() => {
    process.env.STORAGE_BUCKET_NAME = 'lumyra-medical-vault-test';
    process.env.STORAGE_SIGNING_SECRET = 'test-secret-key-12345';
    process.env.STORAGE_ENDPOINT_URL = 'https://vault.internal.lumyra.app';
    service = new StorageService();
  });

  it('should generate a time-limited signed read URL with HMAC signature', async () => {
    const key = 'patients/pat-123/scans/scan-001.png';
    const result = await service.getReadSignedUrl(key, 900);

    expect(result.storageKey).toBe(key);
    expect(result.url).toContain('https://vault.internal.lumyra.app/lumyra-medical-vault-test/');
    expect(result.url).toContain('expires=');
    expect(result.url).toContain('sig=');
    expect(result.expiresAt.getTime()).toBeGreaterThan(Date.now() + 800 * 1000);
    expect(result.expiresAt.getTime()).toBeLessThanOrEqual(Date.now() + 905 * 1000);
  });

  it('should generate a secure direct-to-vault upload grant with sanitized key and patient namespace', async () => {
    const patientId = 'pat-456';
    const grant = await service.getUploadSignedUrl(patientId, 'my_mammogram(2026).dcm', 'application/dicom');

    expect(grant.storageKey).toMatch(/^patients\/pat-456\/scans\/[a-f0-9-]+-my_mammogram_2026_.dcm$/);
    expect(grant.uploadUrl).toContain('action=put');
    expect(grant.uploadUrl).toContain('content_type=application%2Fdicom');
    expect(grant.uploadUrl).toContain('sig=');
    expect(grant.expiresAt.getTime()).toBeGreaterThan(Date.now());
  });
});
