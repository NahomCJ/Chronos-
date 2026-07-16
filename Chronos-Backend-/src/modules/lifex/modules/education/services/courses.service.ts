import prisma from "../models/prisma";
import { CourseFilter } from "../types/education.types";
import { Providers } from "../providers";

/**
 * List Courses with filters + pagination
 */
export const listCourses = async (filter: CourseFilter) => {
  const where: any = {};

  if (filter.provider) where.provider = filter.provider;
  if (filter.level) where.level = filter.level;

  if (filter.tags && filter.tags.length > 0) {
    where.tags = { hasEvery: filter.tags };
  }

  if (filter.q) {
    where.OR = [
      { title: { contains: filter.q, mode: "insensitive" } },
      { description: { contains: filter.q, mode: "insensitive" } },
    ];
  }

  const page = filter.page ?? 1;
  const limit = filter.limit ?? 20;
  const skip = (page - 1) * limit;

  const [items, total] = await Promise.all([
    prisma.course.findMany({
      where,
      take: limit,
      skip,
      orderBy: { createdAt: "desc" },
    }),
    prisma.course.count({ where }),
  ]);

  return {
    items,
    meta: { total, page, limit },
  };
};

/**
 * Get a single course
 */
export const getCourseById = (id: string) => {
  return prisma.course.findUnique({ where: { id } });
};

/**
 * Create a local course manually
 */
export const createLocalCourse = (payload: any) => {
  return prisma.course.create({ data: payload });
};

/**
 * Upsert a course coming from any provider
 * Ensures providerId is unique & stable
 */
export const upsertCourseFromNormalized = async (c: any) => {
  const providerId = c.providerId ?? `${c.provider}_${c.title}`; // fallback to avoid null

  return prisma.course.upsert({
    where: { providerId },
    update: {
      title: c.title,
      description: c.description,
      url: c.url,
      durationHours: c.durationHours,
      level: c.level,
      price: c.price,
      currency: c.currency,
      tags: c.tags || [],
      metadata: c.metadata || {},
    },
    create: {
      provider: c.provider,
      providerId,
      title: c.title,
      description: c.description,
      url: c.url,
      durationHours: c.durationHours,
      level: c.level,
      price: c.price,
      currency: c.currency,
      tags: c.tags || [],
      metadata: c.metadata || {},
    },
  });
};

/**
 * Sync all providers — Coursera, Udemy, EdX, Local, etc.
 */
export const syncAllProviders = async () => {
  const report: any[] = [];

  for (const provider of Providers) {
    try {
      const rawCourses = await provider.fetchCourses();
      let imported = 0;

      for (const r of rawCourses) {
        try {
          const normalized = provider.normalizeCourse(r);
          await upsertCourseFromNormalized(normalized);
          imported++;
        } catch (e) {
          console.error(
            `Upsert error for provider ${provider.name}:`,
            (e as any)?.message || e
          );
        }
      }

      report.push({ provider: provider.name, imported });

    } catch (e) {
      console.error(
        `Provider ${provider.name} sync failed:`,
        (e as any)?.message || e
      );

      report.push({
        provider: provider.name,
        error: (e as any)?.message || String(e),
      });
    }
  }

  return report;
};
