
export interface NormalizedCourse {
provider: string;
providerId: string;
title: string;
description?: string | null;
url?: string | null;
durationHours?: number | null;
level?: string | null;
price?: number | null;
currency?: string | null;
tags?: string[];
metadata?: any;
}


export interface CourseProvider {
name: string;
fetchCourses(): Promise<any[]>; // raw items
normalizeCourse(raw: any): NormalizedCourse;
}
