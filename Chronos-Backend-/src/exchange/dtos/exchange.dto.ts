// src/modules/exchange/dtos/exchange.dto.ts
import { IsString, IsNumber } from "class-validator";

export class CreateExchangeRateDto {
    @IsString()
    baseCurrency: string;

    @IsString()
    targetCurrency: string;

    @IsNumber()
    rate: number;
}

export class ExchangeRequestDto {
    @IsString()
    fromCurrency: string;

    @IsString()
    toCurrency: string;

    @IsNumber()
    amount: number;
}
