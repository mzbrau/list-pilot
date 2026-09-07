---
sidebar_position: 4
---

# Smart ordering

List Pilot keeps your shopping list in aisle order using two layers:

1. **Category aisle order** — the global sequence you set (onboarding and Settings). Every list uses the same category order.
2. **Item order within a category** — learned from how you check items off on that list.

## Category aisle order

On first launch you drag categories into the order that matches your usual path through the shop. Change it anytime under **Settings → Reorder categories**. Updates apply immediately to every shopping list.

Category headers stay stable while you shop — checking off an item does not reshuffle categories.

## Item learning within a category

Each time you check off an item, List Pilot records the event for that list. Over multiple shopping trips it computes median item ranks **within each category**, ignoring bulk checkout taps (when you check several items within a couple of seconds at the end of your shop).

After **three or more trips**, items within a category reorder to match your usual habit.

Sort order uses a composite key: category rank × 10000 + item rank × 100 + a small name tie-break. **Lower ranks appear earlier** on the list. Category rank comes only from your aisle order.

## See learned item ranks

To inspect (and correct) within-category order for a list:

1. Open the list.
2. Tap the **⋮** menu in the app bar.
3. Select **See learned item ranks**.

The screen lists catalog items that have rank stats for that list, including:

- Computed median rank and sample count
- Whether the rank is active yet (needs 3+ samples)
- Any manual override

Tap a row (or the edit icon) to set an **override rank**. Overrides are used for sorting immediately — even if sample count is below three — and are **not overwritten** when ranks are recomputed from later shopping trips.

Use **Undo override** to clear a manual value and return to the live computed median.

## Resetting learned item order

If you want to start fresh for item order on one list:

1. Open the list.
2. Tap the **⋮** menu in the app bar.
3. Select **Reset learned item order**.

This clears learned item ranks and overrides for that list only. Category aisle order is unchanged.

## Ordering diagnostics

In **Settings → Features**, enable **Ordering diagnostics** to show rank details on the shopping list itself:

- Category headers show the aisle-order category rank and its contribution to the sort key
- Each active item shows category/item ranks, sample counts, override markers, and the full sort key

Diagnostics mode is off by default.

## Trip detection

A new shopping trip starts automatically after **4 hours** of inactivity on a list. Check-off events within the same trip contribute to learning; events from separate trips are weighted equally (except bulk checkout taps, which are down-weighted).

:::tip Patience pays off
Within-category smart ordering needs a few shopping trips to kick in. Set your aisle order once, then shop normally — item order adapts without further setup.
:::
