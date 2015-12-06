# TextMate Swift Completions

This is in a non-working state, contributions welcome!

SourceKittenDaemon needs:
- the current (unsaved) contents in the currently open file. 
- the current cursor position in the file
- the current path of the file.

This is impossible to achieve with the simplified textmate plugin api, which only contains information on the current file on disk, as well as the current word for which it needs completions (without context like *where* in the file is this word located.

So instead I've opted to create a textmate plugin which uses the old hardly-used textmate plugin api. In this case, the plugin is written as an objective-c NSBundle which will be loaded by textmate dynamically.

I do have most things working, except for the crucial step:

The documents within textmate are c++ structs of type document_t. I need to dynamically link against this struct in order to be able to read the document properties (cursor position, contents) at runtime. 
However, the current state is that the dynamically linked symbols are mangled anc cannot be found at runtime, and textmate crashes.

# Helping

You can help by trying to get this to work :)

Compiling the project will automatically install it as a textmate plugin (in ~/Library/Application Support/TextMate/PlugIns).
(Compiling will also kill any running textmate instances, so restarting is easier. Make sure you have no unsafed changes).

Once you compiled it, you can re-start Textmate. In the 'Window' menu, there's a new menu entry 'Swift Completions'. If you click the 'Get Completions' menu entry, it will call the code that tries to read something from the `document_t` struct (and textmate crashes).

Looking forward to any contributions.

Once this is solved, getting completions to work should be easy.


