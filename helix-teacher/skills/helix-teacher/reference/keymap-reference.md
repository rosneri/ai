# Helix Keymap Reference

Use this reference when explaining keybindings or helping users remap keys. Helix uses a **selection-first** model inspired by Kakoune: select text first, then apply an action.

## Key differences from Vim

| Action            | Vim    | Helix                | Notes                                      |
| ----------------- | ------ | -------------------- | ------------------------------------------ |
| Delete word       | `dw`   | `wd` (select → act)  | Select with `w`, then delete with `d`      |
| Change word       | `cw`   | `wc`                 | Select with `w`, then change with `c`      |
| Delete line       | `dd`   | `xd`                 | `x` selects the line, `d` deletes          |
| Yank line         | `yy`   | `xy`                 | `x` selects the line, `y` yanks            |
| Visual mode       | `v`    | `v` (select/extend)  | Extend mode — motions extend the selection |
| Select inner word | `viw`  | `miw`                | Match mode `m` → inner `i` → word `w`      |
| Surround          | plugin | `ms(`, `mr(]`, `md(` | Built-in via match mode `m`                |
| Comment toggle    | plugin | `Ctrl-c`             | Built-in                                   |
| File picker       | plugin | `Space f`            | Built-in fuzzy file picker                 |
| Go to definition  | plugin | `gd`                 | Built-in LSP                               |
| Code action       | plugin | `Space a`            | Built-in LSP                               |
| Global search     | plugin | `Space /`            | Built-in ripgrep integration               |

## Normal mode — Movement

| Key             | Description                          | Command                 |
| --------------- | ------------------------------------ | ----------------------- |
| `h` / Left      | Move left                            | `move_char_left`        |
| `j` / Down      | Move down                            | `move_visual_line_down` |
| `k` / Up        | Move up                              | `move_visual_line_up`   |
| `l` / Right     | Move right                           | `move_char_right`       |
| `w`             | Next word start                      | `move_next_word_start`  |
| `b`             | Previous word start                  | `move_prev_word_start`  |
| `e`             | Next word end                        | `move_next_word_end`    |
| `W` / `B` / `E` | Same for WORD (whitespace-delimited) | `move_next_long_word_*` |
| `t`             | Find till next char                  | `find_till_char`        |
| `f`             | Find next char                       | `find_next_char`        |
| `T`             | Find till previous char              | `till_prev_char`        |
| `F`             | Find previous char                   | `find_prev_char`        |
| `G`             | Go to line number                    | `goto_line`             |
| `Alt-.`         | Repeat last motion                   | `repeat_last_motion`    |
| `Ctrl-b`        | Page up                              | `page_up`               |
| `Ctrl-f`        | Page down                            | `page_down`             |
| `Ctrl-u`        | Half page up                         | `page_cursor_half_up`   |
| `Ctrl-d`        | Half page down                       | `page_cursor_half_down` |
| `Ctrl-i`        | Jump forward on jumplist             | `jump_forward`          |
| `Ctrl-o`        | Jump backward on jumplist            | `jump_backward`         |
| `Ctrl-s`        | Save selection to jumplist           | `save_selection`        |

**Note:** Unlike Vim, `f`, `F`, `t`, `T` are not confined to the current line.

## Normal mode — Changes

| Key         | Description                | Command                   |
| ----------- | -------------------------- | ------------------------- |
| `r`         | Replace with character     | `replace`                 |
| `R`         | Replace with yanked text   | `replace_with_yanked`     |
| `~`         | Switch case                | `switch_case`             |
| `` ` ``     | Lowercase                  | `switch_to_lowercase`     |
| `` Alt-` `` | Uppercase                  | `switch_to_uppercase`     |
| `i`         | Insert before selection    | `insert_mode`             |
| `a`         | Append after selection     | `append_mode`             |
| `I`         | Insert at line start       | `insert_at_line_start`    |
| `A`         | Insert at line end         | `insert_at_line_end`      |
| `o`         | Open line below            | `open_below`              |
| `O`         | Open line above            | `open_above`              |
| `.`         | Repeat last insert         | —                         |
| `u`         | Undo                       | `undo`                    |
| `U`         | Redo                       | `redo`                    |
| `Alt-u`     | Move backward in history   | `earlier`                 |
| `Alt-U`     | Move forward in history    | `later`                   |
| `y`         | Yank selection             | `yank`                    |
| `p`         | Paste after                | `paste_after`             |
| `P`         | Paste before               | `paste_before`            |
| `" <reg>`   | Select register            | `select_register`         |
| `>`         | Indent                     | `indent`                  |
| `<`         | Unindent                   | `unindent`                |
| `=`         | Format selection (LSP)     | `format_selections`       |
| `d`         | Delete selection           | `delete_selection`        |
| `Alt-d`     | Delete (no yank)           | `delete_selection_noyank` |
| `c`         | Change selection           | `change_selection`        |
| `Alt-c`     | Change (no yank)           | `change_selection_noyank` |
| `Ctrl-a`    | Increment number           | `increment`               |
| `Ctrl-x`    | Decrement number           | `decrement`               |
| `Q`         | Start/stop macro recording | `record_macro`            |
| `q`         | Replay macro               | `replay_macro`            |

## Normal mode — Selection manipulation

| Key      | Description                       | Command                       |
| -------- | --------------------------------- | ----------------------------- |
| `s`      | Select regex matches in selection | `select_regex`                |
| `S`      | Split selection on regex          | `split_selection`             |
| `Alt-s`  | Split on newlines                 | `split_selection_on_newline`  |
| `&`      | Align selections in columns       | `align_selections`            |
| `_`      | Trim whitespace from selection    | `trim_selections`             |
| `;`      | Collapse selection to cursor      | `collapse_selection`          |
| `Alt-;`  | Flip selection cursor and anchor  | `flip_selections`             |
| `,`      | Keep only primary selection       | `keep_primary_selection`      |
| `Alt-,`  | Remove primary selection          | `remove_primary_selection`    |
| `C`      | Copy selection to next line       | `copy_selection_on_next_line` |
| `Alt-C`  | Copy selection to previous line   | `copy_selection_on_prev_line` |
| `(`      | Rotate main selection backward    | `rotate_selections_backward`  |
| `)`      | Rotate main selection forward     | `rotate_selections_forward`   |
| `%`      | Select entire file                | `select_all`                  |
| `x`      | Select current line(s)            | `extend_line_below`           |
| `X`      | Extend to line bounds             | `extend_to_line_bounds`       |
| `Alt-x`  | Shrink to line bounds             | `shrink_to_line_bounds`       |
| `J`      | Join lines                        | `join_selections`             |
| `K`      | Keep selections matching regex    | `keep_selections`             |
| `Alt-K`  | Remove selections matching regex  | `remove_selections`           |
| `Ctrl-c` | Toggle comments                   | `toggle_comments`             |

## Normal mode — Search

| Key | Description                     |
| --- | ------------------------------- |
| `/` | Search for regex pattern        |
| `?` | Reverse search                  |
| `n` | Next search match               |
| `N` | Previous search match           |
| `*` | Use selection as search pattern |

## Normal mode — Shell

| Key      | Description                           |
| -------- | ------------------------------------- |
| `\|`     | Pipe selection through shell command  |
| `Alt-\|` | Pipe to shell, ignore output          |
| `!`      | Insert shell output before selection  |
| `Alt-!`  | Append shell output after selection   |
| `$`      | Keep selections where shell returns 0 |

## Goto mode (`g`)

| Key  | Description                 | Command                    |
| ---- | --------------------------- | -------------------------- |
| `gg` | File start (or line N)      | `goto_file_start`          |
| `ge` | File end                    | `goto_last_line`           |
| `gh` | Line start                  | `goto_line_start`          |
| `gl` | Line end                    | `goto_line_end`            |
| `gs` | First non-whitespace        | `goto_first_nonwhitespace` |
| `gt` | Top of screen               | `goto_window_top`          |
| `gc` | Center of screen            | `goto_window_center`       |
| `gb` | Bottom of screen            | `goto_window_bottom`       |
| `gd` | Go to definition (LSP)      | `goto_definition`          |
| `gy` | Go to type definition (LSP) | `goto_type_definition`     |
| `gr` | Go to references (LSP)      | `goto_reference`           |
| `gi` | Go to implementation (LSP)  | `goto_implementation`      |
| `ga` | Last accessed file          | `goto_last_accessed_file`  |
| `gm` | Last modified file          | `goto_last_modified_file`  |
| `gn` | Next buffer                 | `goto_next_buffer`         |
| `gp` | Previous buffer             | `goto_previous_buffer`     |
| `g.` | Last modification in file   | `goto_last_modification`   |
| `gw` | Jump labels at words        | `goto_word`                |

## Match mode (`m`)

| Key         | Description                       | Command                    |
| ----------- | --------------------------------- | -------------------------- |
| `mm`        | Go to matching bracket            | `match_brackets`           |
| `ms <ch>`   | Surround selection with `<ch>`    | `surround_add`             |
| `mr <a><b>` | Replace surround `<a>` with `<b>` | `surround_replace`         |
| `md <ch>`   | Delete surround `<ch>`            | `surround_delete`          |
| `ma <obj>`  | Select around text object         | `select_textobject_around` |
| `mi <obj>`  | Select inside text object         | `select_textobject_inner`  |

### Text objects for `ma`/`mi`

| Key       | Object                           |
| --------- | -------------------------------- |
| `w`       | Word                             |
| `W`       | WORD                             |
| `p`       | Paragraph                        |
| `(` / `)` | Parentheses                      |
| `[` / `]` | Brackets                         |
| `{` / `}` | Braces                           |
| `<` / `>` | Angle brackets                   |
| `"`       | Double quotes                    |
| `'`       | Single quotes                    |
| `` ` ``   | Backticks                        |
| `t`       | HTML/XML tag                     |
| `f`       | Function (tree-sitter)           |
| `c`       | Class (tree-sitter)              |
| `a`       | Argument/parameter (tree-sitter) |
| `o`       | Comment (tree-sitter)            |
| `T`       | Test (tree-sitter)               |

## View mode (`z` / sticky `Z`)

| Key  | Description            |
| ---- | ---------------------- |
| `zc` | Center line vertically |
| `zt` | Align to top           |
| `zb` | Align to bottom        |
| `zm` | Center horizontally    |
| `zj` | Scroll down            |
| `zk` | Scroll up              |

## Window mode (`Ctrl-w`)

| Key              | Description            |
| ---------------- | ---------------------- |
| `Ctrl-w v`       | Vertical split         |
| `Ctrl-w s`       | Horizontal split       |
| `Ctrl-w h/j/k/l` | Focus split            |
| `Ctrl-w H/J/K/L` | Swap splits            |
| `Ctrl-w q`       | Close split            |
| `Ctrl-w o`       | Close all other splits |
| `Ctrl-w w`       | Cycle to next split    |

## Space mode (leader)

| Key       | Description                    | Command                                    |
| --------- | ------------------------------ | ------------------------------------------ |
| `Space f` | File picker                    | `file_picker`                              |
| `Space F` | File picker (cwd)              | `file_picker_in_current_directory`         |
| `Space b` | Buffer picker                  | `buffer_picker`                            |
| `Space j` | Jumplist picker                | `jumplist_picker`                          |
| `Space g` | Changed file picker (git)      | `changed_file_picker`                      |
| `Space k` | Hover docs (LSP)               | `hover`                                    |
| `Space s` | Document symbol picker (LSP)   | `symbol_picker`                            |
| `Space S` | Workspace symbol picker (LSP)  | `workspace_symbol_picker`                  |
| `Space d` | Document diagnostics (LSP)     | `diagnostics_picker`                       |
| `Space D` | Workspace diagnostics (LSP)    | `workspace_diagnostics_picker`             |
| `Space r` | Rename symbol (LSP)            | `rename_symbol`                            |
| `Space a` | Code action (LSP)              | `code_action`                              |
| `Space h` | Select symbol references (LSP) | `select_references_to_symbol_under_cursor` |
| `Space '` | Last picker                    | `last_picker`                              |
| `Space /` | Global search                  | `global_search`                            |
| `Space ?` | Command palette                | `command_palette`                          |
| `Space c` | Comment/uncomment              | `toggle_comments`                          |
| `Space C` | Block comment                  | `toggle_block_comments`                    |
| `Space p` | Paste from clipboard           | `paste_clipboard_after`                    |
| `Space P` | Paste clipboard before         | `paste_clipboard_before`                   |
| `Space y` | Yank to clipboard              | `yank_to_clipboard`                        |
| `Space R` | Replace from clipboard         | `replace_selections_with_clipboard`        |
| `Space w` | Window mode                    | —                                          |

## Unimpaired (bracket keys)

| Key                 | Description                      |
| ------------------- | -------------------------------- |
| `]d` / `[d`         | Next / previous diagnostic (LSP) |
| `]D` / `[D`         | Last / first diagnostic          |
| `]f` / `[f`         | Next / previous function (TS)    |
| `]t` / `[t`         | Next / previous type def (TS)    |
| `]a` / `[a`         | Next / previous argument (TS)    |
| `]c` / `[c`         | Next / previous comment (TS)     |
| `]T` / `[T`         | Next / previous test (TS)        |
| `]p` / `[p`         | Next / previous paragraph        |
| `]g` / `[g`         | Next / previous git change       |
| `]Space` / `[Space` | Add newline below / above        |

## Insert mode

| Key      | Description             |
| -------- | ----------------------- |
| `Escape` | Return to normal mode   |
| `Ctrl-s` | Commit undo checkpoint  |
| `Ctrl-x` | Autocomplete            |
| `Ctrl-r` | Insert register content |
| `Ctrl-w` | Delete previous word    |
| `Alt-d`  | Delete next word        |
| `Ctrl-u` | Delete to line start    |
| `Ctrl-k` | Delete to line end      |
| `Ctrl-h` | Delete previous char    |
| `Ctrl-d` | Delete next char        |

## Select / extend mode (`v`)

Same as normal mode but motions extend the selection instead of replacing it. Press `v` again to return to normal mode.

## Key remapping syntax

Remap keys in `config.toml`:

```toml
[keys.normal]
C-s = ":w"                              # Ctrl+S to save
g = { a = "code_action" }               # ga → code action
"ret" = ["open_below", "normal_mode"]   # Enter → open line and return to normal
"A-x" = "@x<A-d>"                       # Macro binding

[keys.insert]
j = { k = "normal_mode" }              # jk → escape

[keys.normal."+"]                        # Minor mode: +m, +c, +t
m = ":run-shell-command make"
c = ":run-shell-command cargo build"
t = ":run-shell-command cargo test"
```

Special key names: `ret`, `space`, `tab`, `del`, `esc`, `backspace`, `left`/`right`/`up`/`down`, `pageup`/`pagedown`, `home`/`end`. Modifiers: `C-` (Ctrl), `A-` (Alt), `S-` (Shift).
