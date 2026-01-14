#!/usr/bin/env python3
"""
Script to update move descriptions with category labels
Priority: Update moves in key categories first
"""

import re

# Map move names to their categories (from updated PBStuff.rb)
move_categories = {
    # Slashing moves
    'AERIALACE': ['Slashing'], 'AIRCUTTER': ['Slashing', 'Wind'], 'AIRSLASH': ['Slashing', 'Wind'],
    'AQUACUTTER': ['Slashing'], 'BEHEMOTHBLADE': ['Slashing'], 'BITTERBLADE': ['Slashing'],
    'CEASELESSEDGE': ['Slashing'], 'CROSSPOISON': ['Slashing'], 'CUT': ['Slashing'],
    'FURYCUTTER': ['Slashing'], 'KOWTOWCLEAVE': ['Slashing'], 'LEAFBLADE': ['Slashing'],
    'MIGHTYCLEAVE': ['Slashing'], 'NIGHTSLASH': ['Slashing'], 'POPULATIONBOMB': ['Slashing'],
    'PSYBLADE': ['Slashing'], 'PSYCHOCUT': ['Slashing'], 'RAZORLEAF': ['Slashing'],
    'RAZORSHELL': ['Slashing'], 'SACREDSWORD': ['Slashing'], 'SECRETSWORD': ['Slashing'],
    'SLASH': ['Slashing'], 'SOLARBLADE': ['Slashing', 'Light'], 'STONEAXE': ['Slashing'],
    'TACHYONCUTTER': ['Slashing'], 'XSCISSOR': ['Slashing'], 'GUILLOTINE': ['Slashing'],

    # Piercing moves
    'HORNATTACK': ['Piercing'], 'FURYATTACK': ['Piercing'], 'POISONSTING': ['Piercing'],
    'TWINEEDLE': ['Piercing'], 'PECK': ['Piercing'], 'DRILLPECK': ['Piercing'],
    'MEGAHORN': ['Piercing'], 'POISONJAB': ['Piercing'], 'NEEDLEARM': ['Piercing'],
    'PLUCK': ['Piercing'], 'DRILLRUN': ['Piercing'], 'HORNLEECH': ['Piercing'],
    'FELLSTINGER': ['Piercing'], 'SMARTSTRIKE': ['Piercing'], 'HORNDRILL': ['Piercing'],
    'SPIRITSHACKLE': ['Piercing'], 'TRIPLEARROWS': ['Piercing', 'Kicking'],
    'ICICLESPEAR': ['Piercing'], 'PINMISSILE': ['Piercing'], 'SPIKECANNON': ['Piercing'],

    # Bludgeoning moves
    'DRAGONTAIL': ['Bludgeoning'], 'POISONTAIL': ['Bludgeoning'], 'IRONTAIL': ['Bludgeoning'],
    'AQUATAIL': ['Bludgeoning'], 'HAMMERARM': ['Bludgeoning', 'Punching'],
    'WOODHAMMER': ['Bludgeoning'], 'CRABHAMMER': ['Bludgeoning'], 'DRAGONHAMMER': ['Bludgeoning'],
    'ICEHAMMER': ['Bludgeoning', 'Punching'], 'BONECLUB': ['Bludgeoning'],
    'BONERUSH': ['Bludgeoning'], 'SHADOWBONE': ['Bludgeoning'], 'POUND': ['Bludgeoning'],
    'SLAM': ['Bludgeoning'], 'ROCKSMASH': ['Bludgeoning'], 'BREAKINGSWIPE': ['Bludgeoning'],
    'DOUBLEIRONBASH': ['Bludgeoning', 'Punching', 'Pinning'],

    # Punching moves
    'BULLETPUNCH': ['Punching'], 'COMETPUNCH': ['Punching'], 'DIZZYPUNCH': ['Punching'],
    'DRAINPUNCH': ['Punching'], 'DYNAMICPUNCH': ['Punching'], 'FIREPUNCH': ['Punching'],
    'FOCUSPUNCH': ['Punching'], 'HEADLONGRUSH': ['Punching'], 'ICEPUNCH': ['Punching'],
    'MACHPUNCH': ['Punching'], 'MEGAPUNCH': ['Punching'], 'METEORMASH': ['Punching'],
    'RAGEFIST': ['Punching'], 'SHADOWPUNCH': ['Punching'], 'SKYUPPERCUT': ['Punching'],
    'THUNDERPUNCH': ['Punching'], 'SUCKERPUNCH': ['Punching'],

    # Kicking moves
    'HIJUMPKICK': ['Kicking', 'Scaling'], 'JUMPKICK': ['Kicking'], 'ROLLINGKICK': ['Kicking'],
    'DOUBLEKICK': ['Kicking'], 'TRIPLEKICK': ['Kicking'], 'LOWKICK': ['Kicking'],
    'BLAZEKICK': ['Kicking'], 'MEGAKICK': ['Kicking'], 'TROPKICK': ['Kicking'],
    'TRIPLEAXEL': ['Kicking'], 'THUNDEROUSKICK': ['Kicking'],

    # Bomb moves
    'ACIDSPRAY': ['Bomb'], 'BARRAGE': ['Bomb'], 'BEAKBLAST': ['Bomb'], 'BULLETSEED': ['Bomb'],
    'EGGBOMB': ['Bomb'], 'FOCUSBLAST': ['Bomb'], 'MAGNETBOMB': ['Bomb'], 'MUDBOMB': ['Bomb'],
    'OCTAZOOKA': ['Bomb'], 'POLLENPUFF': ['Bomb'], 'ROCKBLAST': ['Bomb'],
    'SEARINGSHOT': ['Bomb'], 'SEEDBOMB': ['Bomb'], 'SLUDGEBOMB': ['Bomb'], 'ZAPCANNON': ['Bomb', 'Cannon'],

    # Sound moves (selection)
    'BOOMBURST': ['Sound'], 'BUGBUZZ': ['Sound'], 'CHATTER': ['Sound'],
    'HYPERVOICE': ['Sound'], 'PERISHSONG': ['Sound'], 'ROAR': ['Sound'],
    'SCREECH': ['Sound'], 'SING': ['Sound'], 'SUPERSONIC': ['Sound'], 'UPROAR': ['Sound'],

    # Momentum moves
    'BIDE': ['Momentum'], 'RAPIDSPIN': ['Momentum'], 'MORTALSPIN': ['Momentum'],
    'FLAMEWHEEL': ['Momentum'], 'ROLLOUT': ['Momentum'], 'ICEBALL': ['Momentum'],
}

def get_categories_string(categories):
    """Convert category list to string format"""
    if not categories:
        return ""
    return ". ".join(categories) + "."

def should_strip_description(move_line):
    """Check if move should have description stripped (no secondary effect)"""
    parts = move_line.split(',')
    if len(parts) < 14:
        return False

    # Check if it's a damaging move (basedamage > 0) and category is Physical/Special
    try:
        basedamage = int(parts[4])
        category = parts[7]
        function_code = parts[3]

        # If basedamage > 0 and Physical/Special, and function code is 000 (no effect)
        if basedamage > 0 and category in ['Physical', 'Special'] and function_code == '000':
            return True
    except:
        pass

    return False

def update_move_description(move_line):
    """Update a single move's description with category labels"""
    parts = move_line.split(',')
    if len(parts) < 14:
        return move_line

    move_name = parts[1].upper().replace(' ', '').replace('-', '').replace("'", '')

    if move_name not in move_categories:
        return move_line  # Skip moves not in our priority list

    categories = move_categories[move_name]
    cat_string = get_categories_string(categories)

    # Get current description (last part in quotes)
    desc_match = re.search(r'"([^"]*)"', move_line)
    if not desc_match:
        return move_line

    current_desc = desc_match.group(1)

    # Check if categories already present at end
    for cat in categories:
        if current_desc.rstrip('.').endswith(cat):
            return move_line  # Already updated

    # Determine if we should strip the description
    if should_strip_description(move_line):
        new_desc = cat_string
    else:
        # Add categories to end, removing any trailing period first
        new_desc = current_desc.rstrip('.') + '. ' + cat_string

    # Replace description
    new_line = move_line[:desc_match.start(1)] + new_desc + move_line[desc_match.end(1):]

    return new_line

print("Move description update script ready")
print(f"Will update {len(move_categories)} priority moves")
