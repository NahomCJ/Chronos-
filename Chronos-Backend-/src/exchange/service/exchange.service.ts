// src/modules/exchange/services/exchange.service.ts
import { ExchangeRateModel } from "../models/exchange.model";
import { CreateExchangeRateDto, ExchangeRequestDto } from "../dtos/exchange.dto";

export class ExchangeService {
    async createExchangeRate(data: CreateExchangeRateDto) {
        const rate = new ExchangeRateModel(data);
        return rate.save();
    }

    async getExchangeRate(baseCurrency: string, targetCurrency: string) {
        return ExchangeRateModel.findOne({ baseCurrency, targetCurrency }).exec();
    }

    async exchangeCurrency(data: ExchangeRequestDto) {
        const rateData = await this.getExchangeRate(data.fromCurrency, data.toCurrency);
        if (!rateData) throw new Error("Exchange rate not found.");
        return data.amount * rateData.rate;
    }
}
