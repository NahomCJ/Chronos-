import axios from "axios";
import { CourseProvider, NormalizedCourse } from "./base.provider";


export const CourseraProvider: CourseProvider = {
name: "coursera",


async fetchCourses() {
try {
const res = await axios.get("https://api.coursera.org/api/courses.v1", { params: { limit: 100 } });
return res.data?.elements || [];
} catch (e) {
console.error("[coursera] fetch error", (e as any)?.message || e);
return [];
}
},


normalizeCourse(raw: any): NormalizedCourse {
return {
provider: "coursera",
providerId: raw.id,
title: raw.name ?? raw.title ?? "Untitled",
description: raw.description ?? null,
url: raw.slug ? `https://www.coursera.org/learn/${raw.slug}` : null,
durationHours: raw.estimatedClassWorkload ?? null,
level: raw.level ?? null,
price: null,
currency: "USD",
tags: raw.keywords ?? (raw.domains ? raw.domains.map((d: any) => d.id) : []),
metadata: raw,
};
},
};