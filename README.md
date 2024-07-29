### <span style="color:yellow">Champion! I need assistance! If ur skilled with addon development. Plz help.</span>

# Macronomicon (Auto Macro Tool)

## Description

_<span style="color:#8A2BE2">Within the accursed tome's brittle pages, chaotic
scrawlings converge into an eldritch script, describing macros both alien and
familiar. These arcane glyphs, seething with malevolent life, whisper of spells
unseen by mortal eyes, yet resonant with memories you cannot fully
grasp.</span>_

Are you using Health Potions? What about Healthstones, Mana Potions, or
Explosives? Well this addon might be perfect for you. Macronomicon provides
mutating macros which are auto-refreshed with the best consumables present in
your bags. Macronomicon relieves you of that burden of deciding which consumable
to drag onto your bars. That means you can be comforted by the knowledge that
when you use a Health Potion, the very best was selected from your bags. The
same also applies for the other consumables, if they're available in your bags
of course.

That's not all I've been cooking. As of writing this, I'm working on a _Home
Brewed Mutagen_ feature that will enable you, my friend, to create autoupdating
macros of your very own. This is still experimental, however, and unimplemented.

## Usage

1. Open the Macronomicon UI via the Spellbook. Look for the "Macros" tab near
   the top left.
2. Drag the macros you want onto your action bars.
3. Profit!

## Slash Commands

- `/mcn run`: Forces the addon to refresh.

## Mutating Macros

Basically, the addon attempts to find items which match criterea for predefined
Mutating macros. The "Heal Pot" macro, for instance, should be updated to to use
the best health-potion-esque item available in your bags. This is based on
pattern matching rather than predetermined lists. The benefit of this method is
that we don't rely on lists that canchange over time; by the same token, the
drawback is that the 'intelligence' behind the macros could potentially select
items which match the criterea but are nonetheless undesirable. It might be a
good idea to consider a hybrid model to ensure the macros always produce the
desired result.

## Unimplemented Feature

- More Mutating Macros: Food Buffs, Stat Potions, etc...
- Home Brewed Mutations: Macros that you can make that will update as needed.
- Search: The ability to use the native search box to find macros quickly.
- Glowing/AutoCast Anims.

### <span style="color:#00FF7F">Check out my other addon, [ezquip](https://www.curseforge.com/wow/addons/ezquip)</span>
