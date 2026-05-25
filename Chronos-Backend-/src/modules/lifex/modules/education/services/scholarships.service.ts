import axios from "axios";

const GOOGLE_API_KEY = process.env.GOOGLE_API_KEY;
const GOOGLE_CX = process.env.GOOGLE_CX;

export const searchScholarships = async (query: string) => {
  try {
    const url = `https://www.googleapis.com/customsearch/v1?q=${encodeURIComponent(
      query
    )}&key=${GOOGLE_API_KEY}&cx=${GOOGLE_CX}`;

    const response = await axios.get(url);

    // Map only useful info
    const results = response.data.items?.map((item: any) => ({
      title: item.title,
      link: item.link,
      snippet: item.snippet,
    })) || [];

    return results;
  } catch (error: any) {
    console.error("Google search error:", error.response?.data || error.message);
    throw new Error("Failed to fetch scholarships from Google");
  }
};
