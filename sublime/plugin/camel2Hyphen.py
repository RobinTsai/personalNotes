import sublime
import sublime_plugin

# Sublime Plugin
# You can add this command below in Preferences->Key Binding->User file
# `{ "keys": ["ctrl+b", "ctrl+l"], "command": "camel2_hyphen"}`
# How to use:
# 1. Selected or set the cursor at the the Camel-Case string
# 2. Use Ctrl+k+l to run this command
class Camel2HyphenCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        regions = self.view.sel()
        region = regions[0]
        start = region.begin()
        end = region.end()
        if (start == end):
            region = self.view.word(start)
        selectedText = self.view.substr(region)
        newText = ''
        i = 0
        for index in selectedText:
            if (i == 0):
                newText += index.lower()
            elif (index <= 'Z' and index >= 'A'):
                newText += '-' + index.lower()
            else:
                newText += index
            i += 1
        point = region.begin()
        self.view.erase(edit, region)
        self.view.insert(edit, point, newText)
