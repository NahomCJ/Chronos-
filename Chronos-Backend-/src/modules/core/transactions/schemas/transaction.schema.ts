import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type TransactionDocument = Transaction & Document;

@Schema({ timestamps: true })
export class Transaction {
    @Prop({ required: true })
    fromWalletId: string;

    @Prop({ required: true })
    toWalletId: string;

    @Prop({ required: true })
    amount: number;

    @Prop({ required: true })
    currency: string;

    @Prop({ required: true })
    type: string; // deposit, withdrawal, transfer, exchange

    @Prop({ default: '' })
    description: string;
}

export const TransactionSchema = SchemaFactory.createForClass(Transaction);
