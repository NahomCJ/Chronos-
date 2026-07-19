import fs from "fs";
import path from "path";
import openapiToPostman from "openapi-to-postmanv2";

// Paths
const swaggerFile = path.resolve("./api-docs/swagger.json");
const outputFile = path.resolve("./api-docs/postman_collection.json");

// Read Swagger/OpenAPI JSON
const swaggerData = fs.readFileSync(swaggerFile, "utf8");

// Convert to Postman
openapiToPostman.convert(
  { type: "json", data: swaggerData },
  {},
  (err: any, result: any) => {
    if (err) {
      console.error("Postman conversion error:", err);
      process.exit(1);
    }

    // Save Postman collection
    fs.writeFileSync(outputFile, JSON.stringify(result.output[0].data, null, 2));
    console.log(`✅ Postman collection saved to ${outputFile}`);
  }
);
