---
sidebar_position: 4
---

# Smart ordering

List Pilot learns the order you check items off in each store and reorders future lists to match your usual route.

## How it works

Each time you check off an item, List Pilot records the event for that list. Over multiple shopping trips it computes median category and item ranks, ignoring bulk checkout taps (when you check several items within a couple of seconds at the end of your shop).

After **three or more trips**, the list reorders active items to match your usual path through the store.

Sort order uses a composite key: category rank × 10000 + item rank × 100 + a small name tie-break. **Lower ranks appear earlier** on the list.

## What you'll notice

- Categories may appear in a different order than the defaults.
- Items within a category may reorder based on your habits.
- Each list learns independently — your supermarket route won't affect your hardware store list.

## See learned ranks

To inspect (and correct) what a list has learned:

1. Open the list.
2. Tap the **⋮** menu in the app bar.
3. Select **See learned ranks**.

The screen lists every category and catalog item that has rank stats for that list, including:

- Computed median rank and sample count
- Whether the rank is active yet (needs 3+ samples)
- Any manual override

Tap a row (or the edit icon) to set an **override rank**. Overrides are used for sorting immediately — even if sample count is below three — and are **not overwritten** when ranks are recomputed from later shopping trips.

Use **Undo override** to clear a manual value and return to the live computed median.

## Resetting learned order

If you want to start fresh (e.g. after a store renovation changed the layout):

1. Open the list.
2. Tap the **⋮** menu in the app bar.
3. Select **Reset learned order**.

This clears learned ranks and overrides for that list only. Default category ordering resumes until the app learns again.

## Ordering diagnostics

In **Settings → Features**, enable **Ordering diagnostics** to show rank details on the shopping list itself:

- Category headers show the effective category rank and its contribution to the sort key
- Each active item shows category/item ranks, sample counts, override markers, and the full sort key

Diagnostics mode is off by default.

## Trip detection

A new shopping trip starts automatically after **4 hours** of inactivity on a list. Check-off events within the same trip contribute to learning; events from separate trips are weighted equally (except bulk checkout taps, which are down-weighted).

:::tip Patience pays off
Smart ordering needs a few shopping trips to kick in. Shop normally for the first few visits — the app adapts without any setup.
:::
