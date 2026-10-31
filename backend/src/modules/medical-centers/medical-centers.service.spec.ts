import { MedicalCentersService } from './medical-centers.service';
import { PrismaService } from '../../common/prisma/prisma.service';

describe('MedicalCentersService', () => {
  let service: MedicalCentersService;
  let mockPrisma: any;

  beforeEach(() => {
    process.env.SKIP_DB_CONNECT = 'false';

    mockPrisma = {
      medicalCenter: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
      },
    };
    service = new MedicalCentersService(mockPrisma as PrismaService);
  });

  it('should query centers by governorate and specialties', async () => {
    mockPrisma.medicalCenter.findMany.mockResolvedValue([
      {
        id: 'center-1',
        nameEn: 'National Cancer Institute',
        nameAr: 'المعهد القومي للأورام',
        governorate: 'Cairo',
        specialties: ['Oncology', 'Mammography'],
      },
    ]);

    const results = await service.findAll({
      governorate: 'Cairo',
      mammographyOnly: true,
    });

    expect(results).toHaveLength(1);
    expect(results[0].governorate).toBe('Cairo');
    expect(mockPrisma.medicalCenter.findMany).toHaveBeenCalledWith({
      where: {
        governorate: { contains: 'Cairo', mode: 'insensitive' },
        specialties: { has: 'Mammography' },
      },
      orderBy: [{ governorate: 'asc' }, { nameEn: 'asc' }],
    });
  });

  it('should compute governorate counts correctly', async () => {
    mockPrisma.medicalCenter.findMany.mockResolvedValue([
      { governorate: 'Cairo' },
      { governorate: 'Cairo' },
      { governorate: 'Alexandria' },
    ]);

    const govCounts = await service.getGovernorates();
    expect(govCounts).toEqual([
      { governorate: 'Cairo', count: 2 },
      { governorate: 'Alexandria', count: 1 },
    ]);
  });
});
