import axios from "axios";
import { CourseProvider, NormalizedCourse } from "./base.provider";


export const EdxProvider: CourseProvider = {
name: "edx",


async fetchCourses() {
try {
// EDX has a variety of feeds — this is a placeholder for a real feed or partner API
// Replace URL with an actual edX feed or partner endpoint
const res = await axios.get("https://www.edx.org/api/v1/catalog/search?page=1&page_size=50");
return res.data?.results || [];
} catch (e) {
console.error("[edx] fetch error", (e as any)?.message || e);
return [];
}
},


normalizeCourse(raw: any): NormalizedCourse {
return {
provider: "edx",
providerId: raw.key ?? raw.id ?? String(raw.course_id ?? ""),
title: raw.title ?? raw.name ?? "Untitled",
description: raw.short_description ?? raw.description ?? null,
url: raw.homepage ?? null,
durationHours: null,
level: raw.level ?? null,
price: null,
currency: "USD",
tags: raw.subjects ?? [],
metadata: raw,
};
},
};