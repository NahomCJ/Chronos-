import swaggerAutogen from "swagger-autogen";


const doc = {
  openapi: "3.1.0",
  info: {
    title: "Chronos API",
    description: "Auto-generated from Express routes",
    version: "1.0.0",
  },
  servers: [{ url: "http://localhost:3000/api/v1" }],
  components: {
    schemas: {},
  },
};

const outputFile = "./api-docs/swagger.json";
const endpointsFiles = [
  "./src/routes/index.ts",
  "./src/modules/**/routes/**/*.ts",
];

swaggerAutogen()(outputFile, endpointsFiles, doc);
