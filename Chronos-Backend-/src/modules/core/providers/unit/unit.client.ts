import { Unit } from "@unit-finance/unit-node-sdk";
import { unitConfig } from "./unit.config";

let _client: Unit | null = null;

export function getUnitClient(): Unit {
  if (!unitConfig.token) {
    throw new Error("UNIT_API_TOKEN is not configured");
  }
  if (!_client) {
    _client = new Unit(unitConfig.token, unitConfig.baseUrl);
  }
  return _client;
}
