import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateClinicDto } from './dto/create-clinic.dto';
import { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';

export interface MedicalCenterFilter {
  governorate?: string;
  city?: string;
  search?: string;
  mammographyOnly?: boolean;
  oncologyOnly?: boolean;
}

@Injectable()
export class MedicalCentersService {
  private inMemoryCenters = [
    {
      id: 'mock-center-1',
      slug: 'national-cancer-institute-cairo',
      nameAr: 'المعهد القومي للأورام - جامعة القاهرة',
      nameEn: 'National Cancer Institute (NCI) - Cairo University',
      type: 'HOSPITAL',
      governorate: 'Cairo',
      city: 'Fom El Khalig',
      address: 'Fom El Khalig, Kasr Al Ainy St, Cairo',
      phoneNumber: '+20 2 2368 2030',
      latitude: 30.0267,
      longitude: 31.2333,
      specialties: ['Oncology', 'Mammography', 'Surgical Oncology'],
      isVerified: true,
    },
    {
      id: 'mock-center-2',
      slug: 'baheya-foundation-haram',
      nameAr: 'مستشفى بهية للاكتشاف المبكر وعلاج سرطان الثدي',
      nameEn: 'Baheya Early Detection Hospital',
      type: 'HOSPITAL',
      governorate: 'Giza',
      city: 'Haram',
      address: 'شارع الهرم، الجيزة',
      phoneNumber: '16602',
      latitude: 29.9982,
      longitude: 31.1865,
      specialties: ['Oncology', 'Mammography', 'Screening'],
      isVerified: true,
    },
    {
      id: 'mock-center-3',
      slug: 'dr-nour-breast-clinic',
      nameAr: 'عيادة د. نور الخالدي لجراحة أورام الثدي',
      nameEn: 'Dr. Nour Al-Khalidi Breast Clinic',
      type: 'CLINIC',
      governorate: 'Giza',
      city: 'Mohandessin',
      address: 'عيادات الصفا التخصصية، المهندسين',
      phoneNumber: '+20 100 234 5678',
      latitude: 30.0543,
      longitude: 31.2001,
      specialties: ['Surgical Oncology', 'Biopsy', 'Consultation'],
      isVerified: true,
    },
  ];

  constructor(private readonly prisma: PrismaService) {}

  async findAll(filter: MedicalCenterFilter) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      let results = [...this.inMemoryCenters];
      if (filter.governorate) {
        results = results.filter((c) => c.governorate.toLowerCase() === filter.governorate!.toLowerCase());
      }
      if (filter.city) {
        results = results.filter((c) => c.city.toLowerCase().includes(filter.city!.toLowerCase()));
      }
      if (filter.search) {
        const s = filter.search.toLowerCase();
        results = results.filter(
          (c) =>
            c.nameAr.toLowerCase().includes(s) ||
            c.nameEn.toLowerCase().includes(s) ||
            c.address.toLowerCase().includes(s),
        );
      }
      return results;
    }

    const whereClause: any = {};

    if (filter.governorate) {
      whereClause.governorate = { contains: filter.governorate, mode: 'insensitive' };
    }

    if (filter.city) {
      whereClause.city = { contains: filter.city, mode: 'insensitive' };
    }

    if (filter.search) {
      whereClause.OR = [
        { nameEn: { contains: filter.search, mode: 'insensitive' } },
        { nameAr: { contains: filter.search, mode: 'insensitive' } },
        { address: { contains: filter.search, mode: 'insensitive' } },
      ];
    }

    if (filter.mammographyOnly) {
      whereClause.specialties = { has: 'Mammography' };
    }

    if (filter.oncologyOnly) {
      whereClause.specialties = { has: 'Oncology' };
    }

    return this.prisma.medicalCenter.findMany({
      where: whereClause,
      orderBy: [{ governorate: 'asc' }, { nameEn: 'asc' }],
    });
  }

  async getGovernorates() {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return [{ governorate: 'Cairo', count: 1 }];
    }

    const centers = await this.prisma.medicalCenter.findMany({
      select: { governorate: true },
    });

    const counts: Record<string, number> = {};
    for (const c of centers) {
      counts[c.governorate] = (counts[c.governorate] || 0) + 1;
    }

    return Object.entries(counts)
      .map(([governorate, count]) => ({ governorate, count }))
      .sort((a, b) => b.count - a.count);
  }

  async findOne(id: string) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return {
        id,
        nameAr: 'المعهد القومي للأورام - جامعة القاهرة',
        nameEn: 'National Cancer Institute (NCI) - Cairo University',
        governorate: 'Cairo',
      };
    }

    const center = await this.prisma.medicalCenter.findUnique({
      where: { id },
    });

    if (!center) {
      throw new NotFoundException(`Medical center with ID ${id} not found.`);
    }

    return center;
  }

  async addOrUpdateClinic(user: AuthenticatedUser, dto: CreateClinicDto) {
    const slug = `clinic-${Date.now()}`;
    const newClinic = {
      id: `center-${Date.now()}`,
      slug,
      nameAr: dto.nameAr,
      nameEn: dto.nameEn || dto.nameAr,
      type: dto.type || 'CLINIC',
      governorate: dto.governorate,
      city: dto.city,
      address: dto.address,
      phoneNumber: dto.phoneNumber,
      latitude: dto.latitude,
      longitude: dto.longitude,
      specialties: dto.specialties || ['Oncology', 'Consultation'],
      provenance: 'doctor-registered',
      isVerified: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    if (process.env.SKIP_DB_CONNECT === 'true') {
      this.inMemoryCenters.unshift(newClinic);
      return newClinic;
    }

    return this.prisma.medicalCenter.create({
      data: newClinic,
    });
  }
}
