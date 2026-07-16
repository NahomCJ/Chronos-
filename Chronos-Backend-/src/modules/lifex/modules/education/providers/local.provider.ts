import { CourseProvider, NormalizedCourse } from "./base.provider";


// local provider pulls from your DB (if you have a different ingestion pipeline)
export const LocalProvider: CourseProvider = {
name: "local",


async fetchCourses() {
// local provider intentionally returns empty here; courses already live in DB are "local"
return [];
},


normalizeCourse(raw: any): NormalizedCourse {
// Not used generally; kept for interface completeness
return {
provider: "local",
providerId: raw.id,
title: raw.title,
description: raw.description ?? null,
url: raw.url ?? null,
durationHours: raw.durationHours ?? null,
level: raw.level ?? null,
price: raw.price ?? null,
currency: raw.currency ?? "USD",
tags: raw.tags ?? [],
metadata: raw,
};
},
};