import 'package:flutter/material.dart';

/// One wedge of a ring-chart chat visual.
class ChatRingSlice {
  final String label;
  final double value;
  final Color color;
  const ChatRingSlice({
    required this.label,
    required this.value,
    required this.color,
  });
}

/// One product tile in a chat visual's shopping-result row.
class ChatProductCard {
  final String name;
  final double price;
  final String vendor;
  final bool bnplEligible;
  final String imageUrl;
  const ChatProductCard({
    required this.name,
    required this.price,
    required this.vendor,
    required this.bnplEligible,
    required this.imageUrl,
  });
}

/// A visual attachment Chris can render under a chat reply — a composition
/// ring chart (net worth / portfolio / debt / spending breakdown) or a row
/// of product cards, whichever the user's question called for. Built from
/// data the app's existing Panther usecases already return live; this model
/// only shapes it for the chat bubble.
class ChatVisual {
  final String title;
  final List<ChatRingSlice> slices;
  final String? centerLabel;
  final String? centerSubLabel;
  final List<ChatProductCard> products;

  const ChatVisual.ring({
    required this.title,
    required this.slices,
    this.centerLabel,
    this.centerSubLabel,
  }) : products = const [];

  const ChatVisual.products({
    required this.title,
    required this.products,
  })  : slices = const [],
        centerLabel = null,
        centerSubLabel = null;

  bool get isRing => slices.isNotEmpty;
  bool get isProducts => products.isNotEmpty;
}
