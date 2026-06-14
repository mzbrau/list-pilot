---
sidebar_position: 4
---

# Smart ordering

List Pilot learns the order you check items off in each store and reorders future lists to match your usual route.

## How it works

Each time you check off an item, List Pilot records the event for that list. Over multiple shopping trips it computes median category and item ranks, ignoring bulk checkout taps (when you check several items within a couple of seconds at the end of your shop).

After **three or more trips**, the list reorders active items to match your usual path through the store.

## What you'll notice

- Categories may appear in a different order than the defaults.
- Items within a category may reorder based on your habits.
- Each list learns independently — your supermarket route won't affect your hardware store list.

## Resetting learned order

If you want to start fresh (e.g. after a store renovation changed the layout):

1. Open the list.
2. Tap the **⋮** menu in the app bar.
3. Select **Reset learned order**.

This clears learned ranks for that list only. Default category ordering resumes until the app learns again.

## Trip detection

A new shopping trip starts automatically after **4 hours** of inactivity on a list. Check-off events within the same trip contribute to learning; events from separate trips are weighted equally (except bulk checkout taps, which are down-weighted).

:::tip Patience pays off
Smart ordering needs a few shopping trips to kick in. Shop normally for the first few visits — the app adapts without any setup.
:::
