import sublime, sublime_plugin

class FoldFileComments(sublime_plugin.EventListener):
    def on_load(self, view):
        # view.fold(view.find_by_selector('comment'))
        regions = view.find_by_selector('comment')
        for region in regions:
            newRegion = sublime.Region(region.a + 2, region.b - 1)
            view.fold(newRegion)

class FoldCommentsCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        commentRegion = self.view.find_by_selector('comment')
        # Unfold all
        # self.view.fold(commentRegion)
        for region in commentRegion:
            newRegion = sublime.Region(region.a + 2, region.b - 1)
            self.view.fold(newRegion)

class UnfoldCommentsCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        self.view.unfold(self.view.find_by_selector('comment'))
