#!/usr/bin/env python3
"""Extract ICA receipt line items, translate to English, diff against seed catalog."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

try:
    from pypdf import PdfReader
except ImportError:
    print("Run: tool/.venv/bin/pip install pypdf", file=sys.stderr)
    sys.exit(1)

ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "Reference"
SEED_CATALOG = ROOT / "assets" / "seed_catalog.json"
OUTPUT_EN = Path(__file__).resolve().parent / "receipt_items_en.json"

# Map receipt description prefixes (lowercase) to generic UK-English catalog names.
# Longer / more specific prefixes should appear before shorter ones when using startswith.
DESCRIPTION_TO_ENGLISH: dict[str, tuple[str, str]] = {
    # fruit_veg
    "aktiv-gel citrus": ("Hand sanitiser", "cleaning"),
    "ananasskivor": ("Pineapple slices", "pantry"),
    "aprikos ica": ("Apricots", "fruit_veg"),
    "aprikos 500g": ("Apricots", "fruit_veg"),
    "avocado": ("Avocado", "fruit_veg"),
    "avokado": ("Avocado", "fruit_veg"),
    "ätmogen avokado": ("Avocado", "fruit_veg"),
    "babyplommontom": ("Cherry tomatoes", "fruit_veg"),
    "babyplommontomat": ("Cherry tomatoes", "fruit_veg"),
    "babyspenat": ("Spinach", "fruit_veg"),
    "banan eko": ("Bananas", "fruit_veg"),
    "basilika eko": ("Basil", "fruit_veg"),
    "blåbär odlade": ("Blueberries", "fruit_veg"),
    "blåbär ask": ("Blueberries", "fruit_veg"),
    "broccoli": ("Broccoli", "fruit_veg"),
    "champinjon": ("Mushrooms", "fruit_veg"),
    "champinjoner": ("Mushrooms", "fruit_veg"),
    "citron ica": ("Lemons", "fruit_veg"),
    "cocktailtomater": ("Cherry tomatoes", "fruit_veg"),
    "druva grön": ("Grapes", "fruit_veg"),
    "druva röd": ("Grapes", "fruit_veg"),
    "druva röd/blå": ("Grapes", "fruit_veg"),
    "förkokt majs": ("Sweetcorn", "pantry"),
    "majs förkokt": ("Sweetcorn", "pantry"),
    "gurka svensk": ("Cucumber", "fruit_veg"),
    "hallon": ("Raspberries", "fruit_veg"),
    "jordgubbar": ("Strawberries", "fruit_veg"),
    "jordgubbsskivor": ("Strawberries", "fruit_veg"),
    "kiwi ica": ("Kiwi", "fruit_veg"),
    "kiwi korg": ("Kiwi", "fruit_veg"),
    "kål och morotsmix": ("Coleslaw mix", "fruit_veg"),
    "lime": ("Limes", "fruit_veg"),
    "lök gul": ("Onions", "fruit_veg"),
    "gul lök nät": ("Onions", "fruit_veg"),
    "lök": ("Onions", "fruit_veg"),
    "morot nyskördade": ("Carrots", "fruit_veg"),
    "morot": ("Carrots", "fruit_veg"),
    "mynta": ("Mint", "fruit_veg"),
    "nektarin": ("Nectarines", "fruit_veg"),
    "palsternacka": ("Parsnip", "fruit_veg"),
    "paprika röd": ("Bell peppers", "fruit_veg"),
    "passionsfrukt": ("Passion fruit", "fruit_veg"),
    "persika korg": ("Peaches", "fruit_veg"),
    "peppar röd": ("Chilli peppers", "fruit_veg"),
    "potatis fast": ("Potatoes", "fruit_veg"),
    "potatis mjölig": ("Potatoes", "fruit_veg"),
    "potatis fast ica": ("Potatoes", "fruit_veg"),
    "potatis mjölig ica": ("Potatoes", "fruit_veg"),
    "pumpa butternut": ("Butternut squash", "fruit_veg"),
    "päron conference": ("Pears", "fruit_veg"),
    "rosmarin": ("Rosemary", "fruit_veg"),
    "rödlök nät": ("Red onions", "fruit_veg"),
    "rödlök ica": ("Red onions", "fruit_veg"),
    "sallad isberg": ("Lettuce", "fruit_veg"),
    "salladslök": ("Spring onions", "fruit_veg"),
    "sockerärta": ("Sugar snap peas", "fruit_veg"),
    "soltorkade tomater": ("Sun-dried tomatoes", "fruit_veg"),
    "stjälkselleri": ("Celery", "fruit_veg"),
    "sötpotatis": ("Sweet potatoes", "fruit_veg"),
    "tomat kvist": ("Tomatoes", "fruit_veg"),
    "urkärnade plommon": ("Prunes", "fruit_veg"),
    "zucchini": ("Courgette", "fruit_veg"),
    "ärtor": ("Frozen peas", "frozen"),
    "ärtor,majs,paprika": ("Frozen vegetables mix", "frozen"),
    "granatäpple": ("Pomegranate", "fruit_veg"),
    "picklad rödlök": ("Pickled onions", "other"),
    "småcitrus i korg": ("Oranges", "fruit_veg"),
    "skogsbär": ("Frozen berries", "frozen"),
    "smultron & jordg": ("Strawberries", "fruit_veg"),
    # bread
    "hamburgerbröd": ("Hamburger buns", "bread"),
    "korvbröd": ("Hot dog rolls", "bread"),
    "korvbröd ex durum": ("Hot dog rolls", "bread"),
    "levainbröd": ("Sourdough", "bread"),
    "levain": ("Sourdough", "bread"),
    "norrlands-leväjn": ("Sourdough", "bread"),
    "liba tunnbröd": ("Flatbread", "bread"),
    "pitabröd": ("Pitta bread", "bread"),
    "smörgåsrån": ("Crispbread", "bread"),
    "finn crisp origina": ("Crispbread", "bread"),
    "hönö jollekaka": ("Crispbread", "bread"),
    "hönö skärgårdskaka": ("Crispbread", "bread"),
    "gifflar kanel": ("Cinnamon buns", "bread"),
    "donut/munk": ("Donuts", "snacks"),
    "kladdkaka": ("Cake", "snacks"),
    "barkis": ("Biscuits", "snacks"),
    # meat & fish
    "bacontärningar": ("Bacon", "meat"),
    "bratwurst": ("Sausages", "meat"),
    "chorizo": ("Chorizo", "meat"),
    "minichorizo": ("Chorizo", "meat"),
    "cognacsmedwurst": ("Sausages", "meat"),
    "ex.rökt skinka": ("Ham", "meat"),
    "grillkorv": ("Sausages", "meat"),
    "gyroskebab": ("Kebab meat", "meat"),
    "klassisk kebab": ("Kebab meat", "meat"),
    "karré bbq": ("Pork ribs", "meat"),
    "köttbullar färska": ("Meatballs", "meat"),
    "kycklingbröstfilé": ("Chicken breast", "meat"),
    "kycklingfilé": ("Chicken breast", "meat"),
    "kycklinglårfilé": ("Chicken thighs", "meat"),
    "kyckl.spett asian": ("Chicken breast", "meat"),
    "laxfilé": ("Salmon fillet", "meat"),
    "lövbiff innanlår": ("Steak", "meat"),
    "nötfärs 12%": ("Beef mince", "meat"),
    "pepperbiff": ("Steak", "meat"),
    "prosciutto crudo": ("Prosciutto", "meat"),
    "pulled pork": ("Pulled pork", "meat"),
    "räkor i lake": ("Prawns", "meat"),
    "rökt kalkon tunna": ("Turkey breast", "meat"),
    "salsiccia": ("Sausages", "meat"),
    "sidfläsk bit": ("Bacon", "meat"),
    "tofu naturell": ("Tofu", "meat"),
    "hamburgare bacon": ("Frozen burgers", "frozen"),
    "fish & crisp": ("Fish fingers", "frozen"),
    "fish & fun": ("Fish fingers", "frozen"),
    "krögarpytt klassis": ("Frozen curry", "frozen"),
    "vita bönor": ("White beans", "pantry"),
    # dairy
    "bearnaise chili": ("Béarnaise sauce", "dairy"),
    "bearnaise": ("Béarnaise sauce", "dairy"),
    "creme fraiche": ("Crème fraîche", "dairy"),
    "fam gouda": ("Gouda", "dairy"),
    "gouda skivad": ("Gouda", "dairy"),
    "feta": ("Feta cheese", "dairy"),
    "cream ch vitl&ört": ("Cream cheese", "dairy"),
    "lättsoc vanilj yo": ("Flavoured yogurt", "dairy"),
    "mild yog vanilj": ("Flavoured yogurt", "dairy"),
    "vaniljyog hallon": ("Flavoured yogurt", "dairy"),
    "präst 31%": ("Cheddar cheese", "dairy"),
    "ricotta": ("Ricotta", "dairy"),
    "riven ost": ("Grated cheese", "dairy"),
    "smör ns 82%": ("Butter", "dairy"),
    "smör & raps ns": ("Plant-based spread", "dairy"),
    "brego smör&raps ns": ("Plant-based spread", "dairy"),
    "standmjölk 3%": ("Semi-skimmed milk", "dairy"),
    "vispgrädde 36%": ("Whipping cream", "dairy"),
    "pepper jack ost": ("Pepper jack", "dairy"),
    "red cheddar skiv": ("Cheddar cheese", "dairy"),
    "red hot chili skiv": ("Cheddar cheese", "dairy"),
    "smoked gouda skiv": ("Gouda", "dairy"),
    "ägg 20-p": ("Eggs", "dairy"),
    # frozen
    "pommes criss cut": ("Frozen chips", "frozen"),
    "potatisgratäng": ("Potato gratin", "frozen"),
    "pad thai": ("Frozen curry", "frozen"),
    "ristorante hawaii": ("Frozen pizza", "frozen"),
    "vaniljglass": ("Ice cream", "frozen"),
    "tortellini prosciu": ("Tortellini", "pantry"),
    "tortellini ski/ost": ("Tortellini", "pantry"),
    # cereals
    "crunchy jordg&yogh": ("Crunchy nut cornflakes", "cereals"),
    "havrefras original": ("Oat cereal", "cereals"),
    "havregryn": ("Porridge oats", "cereals"),
    "müsli 45% frukt": ("Muesli", "cereals"),
    "rice krispies": ("Rice Krispies", "cereals"),
    "specflingor jordg": ("Special K", "cereals"),
    "weetabix original": ("Weetabix", "cereals"),
    # pantry
    "arborioris": ("Arborio rice", "pantry"),
    "capellini": ("Pasta", "pantry"),
    "chunky salsa mediu": ("Salsa", "pantry"),
    "fettuccine": ("Pasta", "pantry"),
    "finkrossade tomate": ("Chopped tomatoes", "pantry"),
    "fransk löksoppa": ("Tinned soup", "pantry"),
    "frityrolja": ("Vegetable oil", "pantry"),
    "fusili": ("Pasta", "pantry"),
    "färsk gnocchi": ("Gnocchi", "pantry"),
    "gnocchi": ("Gnocchi", "pantry"),
    "gran biraghi f.riv": ("Parmesan", "dairy"),
    "hoisinsås": ("Hoisin sauce", "pantry"),
    "jasminris": ("Jasmine rice", "pantry"),
    "jasmin ris": ("Jasmine rice", "pantry"),
    "jäst för matbröd": ("Yeast", "pantry"),
    "torrjäst matbröd": ("Yeast", "pantry"),
    "ketchup mindre soc": ("Ketchup", "other"),
    "krispig chili olja": ("Chilli oil", "pantry"),
    "kycklingfond": ("Chicken stock", "pantry"),
    "lasagneplattor": ("Lasagne sheets", "pantry"),
    "majs original extr": ("Sweetcorn", "pantry"),
    "majsstärkelse": ("Cornflour", "pantry"),
    "mandelmassa": ("Marzipan", "pantry"),
    "marsipanlock": ("Marzipan", "pantry"),
    "mörk muscovadorörs": ("Brown sugar", "pantry"),
    "olivolja extra vir": ("Olive oil", "pantry"),
    "pasta spirali": ("Pasta", "pantry"),
    "pastasås campagno": ("Pasta sauce", "pantry"),
    "pastasås ricotta": ("Pasta sauce", "pantry"),
    "penne rigate": ("Penne", "pantry"),
    "pesto alla genoves": ("Pesto", "pantry"),
    "pesto": ("Pesto", "pantry"),
    "potatismjöl": ("Cornflour", "pantry"),
    "real mayonnaise": ("Mayonnaise", "other"),
    "remouladsås": ("Remoulade", "pantry"),
    "risnudlar": ("Rice noodles", "pantry"),
    "rispapper": ("Rice paper", "pantry"),
    "rostad lök": ("Fried onions", "pantry"),
    "senap sötstark": ("Mustard", "other"),
    "senap original": ("Mustard", "other"),
    "senap dijon origin": ("Mustard", "other"),
    "ströbröd": ("Breadcrumbs", "pantry"),
    "taco sauce medium": ("Taco sauce", "pantry"),
    "taco spice mix": ("Taco seasoning", "pantry"),
    "tomatpuré": ("Tomato purée", "pantry"),
    "tomatpure tub": ("Tomato purée", "pantry"),
    "tortilla chips che": ("Tortilla chips", "snacks"),
    "tortilla original": ("Tortilla wraps", "bread"),
    "tortilla originl m": ("Tortilla wraps", "bread"),
    "vanillinsocker": ("Vanilla sugar", "pantry"),
    "vetemjöl": ("Flour", "pantry"),
    "vitlök pressad": ("Garlic", "fruit_veg"),
    "vitvinsvinäger": ("White wine vinegar", "pantry"),
    "äggnudlar": ("Egg noodles", "pantry"),
    "bolognese tomat ba": ("Pasta sauce", "pantry"),
    "flingsalt": ("Salt", "pantry"),
    "ister": ("Lard", "pantry"),
    "jordnötssmör smoot": ("Peanut butter", "pantry"),
    "jordnötter r/s": ("Mixed nuts", "snacks"),
    "jordgubbsmarmelad": ("Jam", "pantry"),
    "röd vinbärsgelè": ("Jam", "pantry"),
    "squeezy hallonsylt": ("Jam", "pantry"),
    "salted caramel": ("Ice cream", "frozen"),
    "soltorkade tomater": ("Sun-dried tomatoes", "fruit_veg"),
    "ame dressing origi": ("Salad cream", "other"),
    "blandsaft hallon": ("Squash", "drinks"),
    "blandsaft s vinbär": ("Squash", "drinks"),
    "paprikapulver": ("Paprika", "pantry"),
    "pärlsocker": ("Pearl sugar", "pantry"),
    "smördeg på smör": ("Frozen pastry", "frozen"),
    "vit c hallon brus": ("Flavoured sparkling drink", "drinks"),
    "vit c blåbär brus": ("Flavoured sparkling drink", "drinks"),
    "blåbärsdryck 3p": ("Flavoured sparkling drink", "drinks"),
    "pärondryck 3p": ("Flavoured sparkling drink", "drinks"),
    "äppeldryck 3p": ("Flavoured sparkling drink", "drinks"),
    "hallondryck": ("Flavoured sparkling drink", "drinks"),
    "fläder/lime": ("Elderflower drink", "drinks"),
    "äppeljuice": ("Apple juice", "drinks"),
    "coca-cola": ("Cola", "drinks"),
    "coca-cola zero": ("Diet cola", "drinks"),
    "fanta orange": ("Cola", "drinks"),
    "vega easy ipa": ("Beer", "drinks"),
    "eko lönnsirap": ("Maple syrup", "pantry"),
    "lönnsirap": ("Maple syrup", "pantry"),
    "hushållsost block": ("Gouda", "dairy"),
    "lager  a.fri": ("Beer", "drinks"),
    "lager a.fri": ("Beer", "drinks"),
    "original": ("Air freshener", "cleaning"),
    "pepparbiff": ("Steak", "meat"),
    "spenat": ("Spinach", "fruit_veg"),
    "kort 1000464": ("Gift card", "household"),
    "kort": ("Gift card", "household"),
    # snacks
    "blåbärsgiffel": ("Pastries", "bread"),
    "cashew r/s": ("Cashews", "snacks"),
    "cashewnötter natur": ("Cashews", "snacks"),
    "choklad mjölk lind": ("Chocolate bar", "snacks"),
    "chokladknappar": ("Chocolate chips", "pantry"),
    "godisburgare": ("Liquorice mix", "snacks"),
    "lösviktsgodis": ("Liquorice mix", "snacks"),
    "naturgodis lösvikt": ("Liquorice mix", "snacks"),
    "fisherm mint sf": ("Throat lozenges", "household"),
    "mjölkchoklad": ("Chocolate bar", "snacks"),
    "oboy original": ("Hot chocolate", "drinks"),
    "ranch&sourcr chips": ("Crisps", "snacks"),
    "soft mint flour": ("Mints", "household"),
    "ögon cacao": ("Hot chocolate", "drinks"),
    "hjärta": ("Chocolate bar", "snacks"),
    # cleaning
    "bad & toalett 16-p": ("Toilet paper", "cleaning"),
    "ica bad & toalett": ("Toilet paper", "cleaning"),
    "bakplåtspapper ark": ("Baking paper", "household"),
    "avfallspåse 30l": ("Bin bags", "cleaning"),
    "diskmaskinssalt": ("Dishwasher salt", "cleaning"),
    "hushållsduk 4p": ("Paper towels", "cleaning"),
    "lemon cream rengör": ("Surface cleaner", "cleaning"),
    "power aio disktabl": ("Dishwasher tablets", "cleaning"),
    "sköljmedel yellow": ("Fabric conditioner", "cleaning"),
    "spolglans": ("Rinse aid", "cleaning"),
    "tvättmaskinreng": ("Washing machine cleaner", "cleaning"),
    "doftblock lavendel": ("Air freshener", "cleaning"),
    "doftblock lemon": ("Air freshener", "cleaning"),
    "aerosol lavender": ("Air freshener", "cleaning"),
    # household
    "ansiktsservetter": ("Face wipes", "household"),
    "bamse tandkräm": ("Children's toothpaste", "household"),
    "batteri lr03 aaa": ("AAA batteries", "household"),
    "batteri lr6 aa": ("AA batteries", "household"),
    "knappcell cr2032": ("Batteries", "household"),
    "bomullspinnar": ("Cotton buds", "household"),
    "caps 8 profondo": ("Coffee pods", "household"),
    "espresso 12 onyx": ("Coffee pods", "household"),
    "espresso profondo": ("Coffee pods", "household"),
    "deodorant ro 48h": ("Deodorant", "household"),
    "deo ro 48h men c": ("Deodorant", "household"),
    "fam fr tvål 750ml": ("Hand soap", "household"),
    "flergångskasse 15l": ("Reusable shopping bag", "household"),
    "hiddensocka broby": ("Socks", "household"),
    "strumpa 3p ränder": ("Socks", "household"),
    "hink 10 l svart": ("Bucket", "household"),
    "hushållspappershål": ("Toilet roll holder", "household"),
    "hydra energet pump": ("Face wash", "household"),
    "ica mat&kök": ("Kitchen knife", "household"),
    "ica merpack äpple": ("Apples", "fruit_veg"),
    "kort 1000464": ("Gift card", "household"),
    "linjal plast 30cm": ("Ruler", "household"),
    "o.b tampong normal": ("Tampons", "household"),
    "presentpapper tårt": ("Gift wrap", "household"),
    "ro sport defence": ("Deodorant", "household"),
    "sticky notes kub 7": ("Sticky notes", "household"),
    "tandk gentle white": ("Toothpaste", "household"),
    "tumstock 2m": ("Tape measure", "household"),
    "tvål shower pink g": ("Shower gel", "household"),
    "original 2118031": ("Air freshener", "cleaning"),
    "guacamole": ("Guacamole", "snacks"),
}

SKIP_PREFIXES = (
    "pant ",
    "betalat",
    "moms ",
    "erhållen rabatt",
    "avrundning",
    "betalningsinformation",
    "term:",
    "butik:",
    "ref:",
    "personlig kod",
    "köp ",
    "varav moms",
    "totalt sek",
    "spara kvittot",
    "få kvittot",
    "läs mer",
    "kosmetik",
    "1 års garanti",
    "originalkvitto",
    "välkommen",
    "returkod",
    "lojalitetspoäng",
    "återbetalning",
    "kontant ",
    "debit mastercard",
    "contactless",
    "datum",
    "tid",
    "org nr",
    "kvitto nr",
    "kassa",
    "kassör",
    "beskrivning",
    "kvitto",
    "maxi ica",
    "gymnasiegatan",
    "44248",
    "störst på",
    "dygnet runt",
    "org.nr",
    "www.maxi",
    "-- ",
)

PRODUCT_LINE = re.compile(
    r"^(\*)?"
    r"(.+?)\s+"
    r"(\d{7})\s+"
    r"[\d,]+\s+"
    r"[\d,]+\s+"
    r"(?:st|kg)\s+"
    r"[\d,]+"
    r"\s*$"
)

DISCOUNT_LINE = re.compile(r"kr/st\s+-[\d,]+$|kr/kg\s+-[\d,]+$|rabatt\d+%\s+-[\d,]+$")


def extract_pdf_text(path: Path) -> str:
    reader = PdfReader(str(path))
    parts: list[str] = []
    for page in reader.pages:
        text = page.extract_text()
        if text:
            parts.append(text)
    return "\n".join(parts)


def parse_receipt(text: str) -> tuple[str | None, str | None, list[str]]:
    date_match = re.search(r"^(\d{4}-\d{2}-\d{2})$", text, re.MULTILINE)
    receipt_match = re.search(r"^(\d{4})$", text, re.MULTILINE)
    date = date_match.group(1) if date_match else None

    receipt_no = None
    lines = text.splitlines()
    for i, line in enumerate(lines):
        if line.strip() == "Kvitto nr" and i + 1 < len(lines):
            receipt_no = lines[i + 1].strip()
            break

    descriptions: list[str] = []
    for raw in lines:
        line = raw.strip()
        if not line:
            continue
        lower = line.lower()
        if any(lower.startswith(p) for p in SKIP_PREFIXES):
            continue
        if DISCOUNT_LINE.search(lower):
            continue
        if re.match(r"^kort [\d,]+$", lower):
            continue
        match = PRODUCT_LINE.match(line)
        if not match:
            continue
        desc = match.group(2).strip()
        descriptions.append(desc)
    return date, receipt_no, descriptions


def translate_description(desc: str) -> tuple[str, str] | None:
    key = desc.lstrip("*").strip().lower()
    for prefix, value in sorted(DESCRIPTION_TO_ENGLISH.items(), key=lambda x: -len(x[0])):
        if key.startswith(prefix):
            return value
    return None


def load_seed_names() -> set[str]:
    data = json.loads(SEED_CATALOG.read_text(encoding="utf-8"))
    return {item["name"].lower() for item in data["items"]}


def apply_to_seed_catalog(new_items: dict[str, str]) -> None:
    data = json.loads(SEED_CATALOG.read_text(encoding="utf-8"))
    existing = {item["name"].lower() for item in data["items"]}
    category_order = [c["id"] for c in data["categories"]]

    additions = [
        {"name": name, "categoryId": category}
        for name, category in sorted(new_items.items(), key=lambda x: x[0].lower())
        if name.lower() not in existing
    ]
    if not additions:
        return

    by_category: dict[str, list[dict[str, str]]] = {cid: [] for cid in category_order}
    for item in data["items"]:
        by_category[item["categoryId"]].append(item)
    for item in additions:
        by_category[item["categoryId"]].append(item)

    merged: list[dict[str, str]] = []
    for cid in category_order:
        merged.extend(
            sorted(by_category[cid], key=lambda i: i["name"].lower())
        )

    data["items"] = merged
    SEED_CATALOG.write_text(
        json.dumps(data, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(f"Updated {SEED_CATALOG} (+{len(additions)} items, total {len(merged)})")


def main() -> None:
    apply = "--apply" in sys.argv
    seen_trips: set[tuple[str | None, str | None]] = set()
    raw_items: set[str] = set()
    translated: dict[str, tuple[str, str]] = {}
    unmapped: set[str] = set()

    for pdf in sorted(REFERENCE.glob("*.pdf")):
        text = extract_pdf_text(pdf)
        date, receipt_no, descriptions = parse_receipt(text)
        trip_key = (date, receipt_no)
        if trip_key in seen_trips and date and receipt_no:
            continue
        seen_trips.add(trip_key)

        for desc in descriptions:
            raw_items.add(desc)
            mapping = translate_description(desc)
            if mapping is None:
                unmapped.add(desc)
            else:
                translated[desc] = mapping

    seed_names = load_seed_names()
    new_items: dict[str, str] = {}
    for _desc, (english, category) in translated.items():
        if english.lower() not in seed_names and english not in new_items:
            new_items[english] = category

    result = {
        "receiptTrips": len(seen_trips),
        "rawItemCount": len(raw_items),
        "mappedItemCount": len(translated),
        "unmapped": sorted(unmapped),
        "newCatalogItems": [
            {"name": name, "categoryId": category}
            for name, category in sorted(new_items.items(), key=lambda x: x[0].lower())
        ],
    }

    OUTPUT_EN.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Trips: {result['receiptTrips']}")
    print(f"Raw items: {result['rawItemCount']}")
    print(f"Mapped: {result['mappedItemCount']}")
    print(f"Unmapped: {len(unmapped)}")
    if unmapped:
        print("Unmapped items:")
        for item in sorted(unmapped):
            print(f"  - {item}")
    print(f"New catalog items to add: {len(new_items)}")
    for item in result["newCatalogItems"]:
        print(f"  + {item['name']} ({item['categoryId']})")

    if apply and new_items:
        apply_to_seed_catalog(new_items)


if __name__ == "__main__":
    main()
