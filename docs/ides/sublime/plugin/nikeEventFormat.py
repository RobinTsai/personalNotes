import sublime
import sublime_plugin

# This is the plugin only used for NIKEjdi project
# It will trasnfer the Object-Array (every object not have child obj or arr) to json object in every line
# It do some works below:
# erase all '[' and ']'
# Then erase all "\n"
# Finally find all '},' and replace with '}\n'

# How to use:
# Put this file in your Packages->User direction
# Config your sublime keyBinding in your user keybinding config file as:
    # { "keys": ["ctrl+b", "ctrl+k"], "command": "nike_event_format"}
# Then press down 'ctrl', 'b', 'k' one by one and lossen them at the same time
# - END -
class NikeEventFormatCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        print('abc')
        bracketRegions = self.view.find_all('\[|\]', 0)
        bracketRegions.reverse()

        for region in bracketRegions:
            self.view.erase(edit, region)

        eofRegions = self.view.find_all("\n", 0)
        eofRegions.reverse()
        for region in eofRegions:
            self.view.erase(edit, region)

        needEofRegions = self.view.find_all('},', 0)
        needEofRegions.reverse()
        for region in needEofRegions:
            self.view.replace(edit, region, "}\n")
