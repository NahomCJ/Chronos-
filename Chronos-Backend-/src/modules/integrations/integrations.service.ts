import AkoyaService from "./services/akoya.service";
import MoralisService from "./services/moralis.service";
import FinGPTService from "./services/fingpt.service";

type IntegrationServiceName = "akoya" | "moralis" | "fingpt";

class IntegrationsService {
  // Dispatches calls to the right integration
  async call(service: IntegrationServiceName, method: string, params: any) {
    switch (service) {
      case "akoya":
        if (!(method in AkoyaService)) throw new Error(`Akoya method ${method} not found`);
        return (AkoyaService as any)[method](params);

      case "moralis":
        if (!(method in MoralisService)) throw new Error(`Moralis method ${method} not found`);
        return (MoralisService as any)[method](params);

      case "fingpt":
        if (!(method in FinGPTService)) throw new Error(`FinGPT method ${method} not found`);
        return (FinGPTService as any)[method](params);

      default:
        throw new Error(`Unknown integration service: ${service}`);
    }
  }
}

export default new IntegrationsService();
