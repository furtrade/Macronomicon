Creating a macro:

1. call CreateCustomMacro
<!-- Setting up the UI box -->
2. AceGUI:Create("Frame")
3. AceGUI:Create("EditBox")
4. editBox:SetCallback("OnEnterPressed", function(widget, event, text)
<!-- Getting the user's input text -->
5. local macroKey = text
<!-- Setting up the macroInfo table -->
6. local macroInfo = {...}
<!-- Updating db and macroData table with the new macro -->
7. self.db.profile[macroKey] = macroInfo
8. self:loadCustomMacros() 
<!-- Update the macroSelect values -->
9. self.options.args.mainGroup.args.macroSelect.values = self:GetMacroNames() --
<!-- Select the new custom macro -->
10. self:SetSelectedMacro(nil, macroKey)
