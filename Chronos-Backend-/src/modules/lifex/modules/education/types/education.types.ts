export interface CourseFilter {
provider?: string;
tags?: string[];
level?: string;
priceMin?: number;
priceMax?: number;
q?: string;
page?: number;
limit?: number;
}