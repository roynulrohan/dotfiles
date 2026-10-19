# Writing

These rules apply to every Markdown file and every comment that the owner or
an agent writes in this repo. They do not apply to text that a tool writes,
such as `btop.conf`, the descriptions from `brew bundle dump` or LinearMouse's
config, or to work copied in from others
([`CREDITS.md`](CREDITS.md)).

## Decide what goes in the repo

1. Before you write or rewrite a line, check that it is true. Check it
   against the config, the script or the live system. Then check that the
   line needs to exist and that this file is its home. Change the wording
   last.
2. Record a fact only if a config or a step depends on it, if a rebuild needs
   it, if it stops a likely wrong change, or if it is a lasting preference.
3. Keep sessions out of the repo: tuning, test runs, crash hunts and compared
   options. The commit body and the agent's own notes hold them.
4. Record the result, not the evidence. Keep a number only when a value
   depends on it, such as the baseline behind a limit.
5. Record a value when it settles. Update its home in the same commit. If you
   find a stale fact, fix it or tell the owner.
6. If you are not sure that a fact belongs, ask the owner. Do not drop it
   silently.

## Give each fact one home

| Fact | Home |
|---|---|
| What a value does, or why it is unusual | A comment beside the value. Use the package's `SETUP.md` when the file can't hold comments or the app rewrites it. |
| How a script or plugin works inside | Its own comments, or a README beside it |
| How to install, use and check a package | Its `SETUP.md` |
| Hardware, the packages a machine takes, settings outside the repo (BIOS, firmware, app settings windows) | [`personal/machines/`](personal/machines/gaming-pc.md) |
| A lasting preference, a hard no, an option the owner rejected | [`personal/preferences.md`](personal/preferences.md) |
| Why something changed, and what was tried | The commit body |

7. In other places, link to the home. Repeat a fact only where the reader
   must act on it, such as a checklist step or a warning before a step.

## Keep reasons, hazards and workarounds

8. Give a reason when a reader would be surprised by a value or would undo
   it. Leave out reasons that the value makes obvious.
9. Keep each hazard: what breaks, the message that identifies it, and how to
   recover.
10. Give a workaround one line: what it works around, one upstream link, and
   when to remove it ("until mpv 0.42"). The rest of the investigation goes in
   the commit body.
11. Name a source only for something that is taken from it and is distinctive
    to it, such as a theme, an animation set or a script. A default or a
    common setting that happened to come from a framework gets no note. "We
    used X before" goes, unless it records a preference.
12. Keep the cases that the config handles, also for hardware that a machine
    does not have now. Do not write guesses. Test the case or leave it out.

## Write each doc for its reader

13. `README.md` is the owner's showcase, in his voice. No install steps and no
    history.
14. `INSTALL.md` gives other people the steps, with links to each `SETUP.md`.
    Nothing about the owner's machines, media or sign-ins.
15. `SETUP.md` has the sections Files, Install, Notes and Verify, in that
    order. Notes is optional. It holds what a reader needs to use or change
    the package. Verify gives commands and their expected output.
16. `personal/` is for the owner and agents. In a machine file, keep the
    checklists apart from the tables of settings.
17. Agent files give a map, the rules and the hazards, as commands.
18. A commit body says why, and which options were rejected, in a few
    sentences. Give the numbers that decided it. No logs and no session
    notes.

## Use ASD-STE100 language

19. Write one idea per sentence. Keep instructions to about 20 words and
    other sentences to about 25.
20. Use the active voice. Write instructions as commands. Put a condition or a
    warning before its step.
21. Use one word for one thing. Use the real names of files, keys, commands
    and tools, not names from a conversation.
22. Do not use filler, figures of speech, em dashes, slashes between words or
    `etc.`. In prose, use periods, not semicolons.
23. When you change a sentence, rewrite it for the reader. Do not add clauses
    to the end. Do not edit text that you have no reason to touch.
24. If a rule makes a sentence worse, write the sentence another way.

[`check.sh`](check.sh) checks only the clear patterns: the `SETUP.md`
sections, dates and history phrases in `SETUP.md`, `README.md` and
`INSTALL.md`, and em dashes and `etc.` in Markdown prose. The writer and the
reviewer apply the other rules.
