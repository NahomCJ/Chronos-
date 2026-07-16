// src/modules/exchange/models/exchange.model.ts
import mongoose, { Document, Schema } from "mongoose";
import { ExchangeRate } from "../exchange.types";

export interface ExchangeRateDocument extends ExchangeRate, Document { }

const ExchangeRateSchema: Schema = new Schema(
    {
        baseCurrency: { type: String, required: true },
        targetCurrency: { type: String, required: true },
        rate: { type: Number, required: true },
    },
    { timestamps: true }
);

export const ExchangeRateModel = mongoose.model<ExchangeRateDocument>(
    "ExchangeRate",
    ExchangeRateSchema
);
