// src/modules/exchange/controllers/exchange.controller.ts
import { Request, Response } from "express";
import { ExchangeService } from "../services/exchange.service";
import { CreateExchangeRateDto, ExchangeRequestDto } from "../dtos/exchange.dto";

export class ExchangeController {
    private exchangeService = new ExchangeService();

    async createRate(req: Request, res: Response) {
        try {
            const dto = req.body as CreateExchangeRateDto;
            const rate = await this.exchangeService.createExchangeRate(dto);
            res.status(201).json(rate);
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }

    async getRate(req: Request, res: Response) {
        try {
            const { baseCurrency, targetCurrency } = req.params;
            const rate = await this.exchangeService.getExchangeRate(baseCurrency, targetCurrency);
            if (!rate) return res.status(404).json({ error: "Rate not found" });
            res.json(rate);
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }

    async exchange(req: Request, res: Response) {
        try {
            const dto = req.body as ExchangeRequestDto;
            const result = await this.exchangeService.exchangeCurrency(dto);
            res.json({ result });
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }
}
