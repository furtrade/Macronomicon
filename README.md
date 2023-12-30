### <span style="color:yellow">Champion! I need assistance! If ur skilled with addon UI design. Plz help.</span>

# Macrobial | Auto Potion Tool

## Description

Are you using Health Potions? What about Healthstones, Mana Potions, or
Explosives? Well this addon might be perfect for you. Macrobial provides curated
macros which are auto-refreshed with the best consumables present in your bags.
Macrobial relieves you of that burden of deciding which consumable to drag onto
your bars. That means you can be comforted by the knowledge that when you use a
Health Potion, the very best was selected from your bags. The same also applies
for the other consumables, if they're available in your bags of course.

That's not all I've been cooking. As of writing this, I'm working on a _Super
Macro Patching_ feature that will enable you, my friend, to create autoupdating
macros of your very own. This is still experimental, however.

## Usage

1. Open the Macrobial UI panel through the game's options menu or type `/mbl`.
2. Select the macro you would like to enable, toggle it on.
3. Type `/m` and find the corresponding macro, and drag it onto your bars.
4. Profit!

## Experimental Feature

1. Use the "Create Custom Macro" button to create a new macro. Note: The new
   macro will not immediately appear in the list of macros. You will need to
   close and reopen the UI to see the change.
2. Select the newly created macro to view the options for it.
3. Add your own macro string to the box.
4. Type `/m` and find the corresponding macro, drag it onto your bars.
5. Macrobial will attempt to patch your macro when various conditions are met.

For example, if you entered a macro like  
`/cast [known:master channeler] drain life; corruption`  
Macrobial will check if you know _Master Channeler_, then patch the macro
accordingly. If known, the result will be  
`/cast drain life`.  
Else the result will be  
`/cast corruption`.

## Slash Commands

- `/mbl` or `/macrobial`: Opens the Macrobial UI panel.
- `/mbl run`: Forces the addon to refresh.
