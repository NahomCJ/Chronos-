import axios from "axios";
import { CourseProvider, NormalizedCourse } from "./base.provider";


export const UdemyProvider: CourseProvider = {
name: "udemy",


async fetchCourses() {
try {
const token = process.env.UDEMY_API_KEY || ""; // expecting Basic auth value if used
const res = await axios.get("https://www.udemy.com/api-2.0/courses/", {
params: { page_size: 50 },
headers: token ? { Authorization: `Basic ${token}` } : {},
});
return res.data?.results || [];
} catch (e) {
console.error("[udemy] fetch error", (e as any)?.message || e);
return [];
}
},


normalizeCourse(raw: any): NormalizedCourse {
return {
provider: "udemy",
providerId: String(raw.id),
title: raw.title ?? "Untitled",
description: raw.headline ?? raw.description ?? null,
url: raw.url ? `https://www.udemy.com${raw.url}` : null,
durationHours: raw.content_length ? Number(raw.content_length) / 3600 : null,
level: raw.level ?? null,
price: raw.price_detail ? Number(raw.price_detail.amount) : null,
currency: raw.price_detail ? raw.price_detail.currency : "USD",
tags: raw.visible_instructors ? raw.visible_instructors.map((i: any) => i.name) : [],
metadata: raw,
};
},
};