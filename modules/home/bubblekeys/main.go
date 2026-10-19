// bubblekeys: niri's keybinds as a cheat sheet you can filter. Reads the live
// niri config, so every bind is there (not only the titled ones), groups them
// by what they do, and draws each group in its own terminal colour, so the
// terminal theme rules. Type to filter; Esc clears the filter, then closes.
package main

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// ----- groups -----

type group struct {
	name  string
	icon  string
	color lipgloss.Color
}

// In display order. Colours are ANSI indexes: the terminal theme decides them.
var groups = []group{
	{"Majorlink", "\U000F036C", "5"},
	{"Apps", "", "4"},
	{"Clipboard", "", "6"},
	{"Notifications", "", "3"},
	{"Windows", "", "2"},
	{"Columns", "", "6"},
	{"Workspaces", "", "4"},
	{"Monitors", "\U000F0379", "13"},
	{"Screenshots", "", "11"},
	{"Media", "", "9"},
	{"System", "", "1"},
}

const (
	gMajorlink = iota
	gApps
	gClipboard
	gNotifications
	gWindows
	gColumns
	gWorkspaces
	gMonitors
	gScreenshots
	gMedia
	gSystem
)

// ----- parsing -----

type bind struct {
	key    string // as written: Mod+Shift+Left
	action string // focus-column-left
	args   []string
	title  string
}

var (
	bindRe  = regexp.MustCompile(`^\s*([A-Za-z0-9_+]+)\s*(.*?)\{\s*(.*?)\s*;?\s*\}\s*$`)
	titleRe = regexp.MustCompile(`hotkey-overlay-title="((?:[^"\\]|\\.)*)"`)
	argRe   = regexp.MustCompile(`"((?:[^"\\]|\\.)*)"|(\S+)`)
)

func parse(text string) []bind {
	var out []bind
	in := false
	for _, line := range strings.Split(text, "\n") {
		t := strings.TrimSpace(line)
		if !in {
			in = strings.HasPrefix(t, "binds {")
			continue
		}
		if t == "}" {
			break
		}
		if strings.HasPrefix(t, "//") {
			continue
		}
		m := bindRe.FindStringSubmatch(line)
		if m == nil {
			continue
		}
		b := bind{key: m[1]}
		if tm := titleRe.FindStringSubmatch(m[2]); tm != nil {
			b.title = tm[1]
		}
		for i, a := range argRe.FindAllStringSubmatch(m[3], -1) {
			v := a[2]
			if a[1] != "" || strings.HasPrefix(a[0], `"`) {
				v = a[1]
			}
			if i == 0 {
				b.action = v
			} else {
				b.args = append(b.args, v)
			}
		}
		out = append(out, b)
	}
	return out
}

// ----- describing -----

var mediaNames = map[string]string{
	"wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0": "Volume up",
	"wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-":        "Volume down",
	"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle":        "Mute",
	"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle":      "Mic mute",
	"playerctl play-pause":                              "Play / pause",
	"playerctl stop":                                    "Stop",
	"playerctl previous":                                "Previous track",
	"playerctl next":                                    "Next track",
	"pkill orca || exec orca":                           "Screen reader",
}

// Short names for niri's own actions; the group heading says what they act
// on (Columns: "Focus left"). They win over a title, which niri's overlay
// needed to stand on its own.
var actionNames = map[string]string{
	"close-window": "Close", "focus-window-down": "Focus down", "focus-window-up": "Focus up",
	"move-window-down": "Move down", "move-window-up": "Move up",
	"consume-or-expel-window-left": "In / out of column left", "consume-or-expel-window-right": "In / out of column right",
	"consume-window-into-column": "Into the column", "expel-window-from-column": "Out of the column",
	"switch-preset-window-height": "Next height", "reset-window-height": "Reset height",
	"fullscreen-window": "Fullscreen", "maximize-window-to-edges": "Maximize to edges",
	"switch-focus-between-floating-and-tiling": "Floating ⇄ tiling",
	"focus-column-left":                        "Focus left", "focus-column-right": "Focus right",
	"move-column-left": "Move left", "move-column-right": "Move right",
	"focus-column-first": "Focus first", "focus-column-last": "Focus last",
	"move-column-to-first": "Move to first", "move-column-to-last": "Move to last",
	"switch-preset-column-width": "Next width", "maximize-column": "Maximize",
	"expand-column-to-available-width": "Fill the space", "center-column": "Center",
	"center-visible-columns": "Center visible", "toggle-column-tabbed-display": "Tabs on / off",
	"set-column-width": "Width", "set-window-height": "Height",
	"focus-workspace-down": "Focus down", "focus-workspace-up": "Focus up",
	"move-column-to-workspace-down": "Move column down", "move-column-to-workspace-up": "Move column up",
	"move-workspace-down": "Move workspace down", "move-workspace-up": "Move workspace up",
	"focus-workspace": "Focus", "move-column-to-workspace": "Move column to",
	"focus-monitor-left": "Focus left", "focus-monitor-right": "Focus right",
	"focus-monitor-down": "Focus down", "focus-monitor-up": "Focus up",
	"move-column-to-monitor-left": "Move column left", "move-column-to-monitor-right": "Move column right",
	"screenshot": "Area", "screenshot-screen": "Screen", "screenshot-window": "Window",
	"quit": "Exit niri", "power-off-monitors": "Monitors off", "toggle-overview": "Overview",
	"toggle-keyboard-shortcuts-inhibit": "Keys to the app on / off",
	"show-hotkey-overlay":               "niri's hotkey overlay",
}

func describe(b bind) string {
	if n, ok := actionNames[b.action]; ok {
		if len(b.args) > 0 {
			return n + " " + strings.Join(b.args, " ")
		}
		return n
	}
	if b.title != "" {
		t := strings.TrimPrefix(b.title, "Majorlink: ")
		return strings.ToUpper(t[:1]) + t[1:]
	}
	cmd := strings.Join(b.args, " ")
	if n, ok := mediaNames[cmd]; ok {
		return n
	}
	switch b.action {
	case "spawn", "spawn-sh":
		if strings.Contains(cmd, "brightnessctl") && strings.Contains(cmd, "+") {
			return "Screen brighter"
		}
		if strings.Contains(cmd, "brightnessctl") {
			return "Screen dimmer"
		}
		if len(cmd) > 40 {
			cmd = cmd[:39] + "…"
		}
		return "Run " + cmd
	}
	s := strings.ReplaceAll(b.action, "-", " ")
	s = strings.ToUpper(s[:1]) + s[1:]
	if len(b.args) > 0 {
		s += " " + strings.Join(b.args, " ")
	}
	return s
}

func classify(b bind) int {
	cmd := strings.Join(b.args, " ")
	a := b.action
	switch {
	case strings.Contains(cmd, "majorlink") || strings.HasPrefix(b.title, "Majorlink"):
		return gMajorlink
	case strings.HasPrefix(b.key, "XF86") || strings.Contains(cmd, "playerctl") || strings.Contains(cmd, "wpctl") || strings.Contains(cmd, "mic-effects"):
		return gMedia
	case strings.Contains(a, "screenshot"):
		return gScreenshots
	case strings.Contains(cmd, "makoctl"):
		return gNotifications
	case strings.Contains(cmd, "cliphist") || strings.Contains(cmd, "wl-copy"):
		return gClipboard
	case strings.Contains(cmd, "swaylock") || strings.Contains(cmd, "orca") || strings.Contains(cmd, "bubblekeys"):
		return gSystem
	case a == "spawn" || a == "spawn-sh":
		return gApps
	case a == "power-off-monitors":
		return gSystem
	case strings.Contains(a, "monitor"):
		return gMonitors
	case strings.Contains(a, "workspace"):
		return gWorkspaces
	case strings.Contains(a, "window") || strings.Contains(a, "floating"):
		return gWindows
	case strings.Contains(a, "column"):
		return gColumns
	}
	return gSystem
}

// ----- keys -----

var keyNames = map[string]string{
	"Mod": "Super", "SHIFT": "Shift", "Left": "←", "Right": "→", "Up": "↑", "Down": "↓",
	"Page_Up": "PgUp", "Page_Down": "PgDn", "Return": "Enter", "Plus": "+", "plus": "+",
	"Minus": "-", "Equal": "=", "BracketLeft": "[", "BracketRight": "]", "Comma": ",",
	"Period": ".", "Slash": "/", "Escape": "Esc", "Delete": "Del", "Print": "PrtSc",
	"WheelScrollUp": "scroll ↑", "WheelScrollDown": "scroll ↓",
	"WheelScrollLeft": "scroll ←", "WheelScrollRight": "scroll →",
	"XF86AudioRaiseVolume": "Vol +", "XF86AudioLowerVolume": "Vol −", "XF86AudioMute": "Mute",
	"XF86AudioMicMute": "Mic mute", "XF86AudioPlay": "Play", "XF86AudioStop": "Stop",
	"XF86AudioPrev": "Prev", "XF86AudioNext": "Next", "XF86MonBrightnessUp": "Bright +",
	"XF86MonBrightnessDown": "Bright −", "XF86Keyboard": "Kbd light",
}

var modOrder = map[string]int{"Super": 0, "Ctrl": 1, "Shift": 2, "Alt": 3}

func keyParts(k string) []string {
	var out []string
	for _, p := range strings.Split(k, "+") {
		if n, ok := keyNames[p]; ok {
			p = n
		}
		out = append(out, p)
	}
	mods := out[:len(out)-1]
	sort.SliceStable(mods, func(i, j int) bool { return modOrder[mods[i]] < modOrder[mods[j]] })
	return out
}

// Modifiers as icons: Super ❖ (neither a Windows nor a Mac key, and simple
// enough to stay clean at small sizes; the NixOS snowflake was not), Ctrl,
// Shift and Alt the keyboard symbols. The names stay in the search text, so
// typing "shift" still finds them.
var modIcons = map[string]string{"Super": "❖", "Ctrl": "\U000F0634", "Shift": "\U000F0636", "Alt": "\U000F0635"}

// Combos that share their modifiers drawn once: Super Ctrl ←/H.
func renderCombos(combos [][]string, color lipgloss.Color) string {
	key := lipgloss.NewStyle().Foreground(color).Bold(true)
	type set struct {
		mods []string
		keys []string
	}
	var sets []*set
	byMods := map[string]*set{}
	for _, c := range combos {
		id := strings.Join(c[:len(c)-1], "+")
		st, ok := byMods[id]
		if !ok {
			st = &set{mods: c[:len(c)-1]}
			byMods[id] = st
			sets = append(sets, st)
		}
		st.keys = append(st.keys, c[len(c)-1])
	}
	var out []string
	for _, st := range sets {
		var parts []string
		for _, m := range st.mods {
			if icon, ok := modIcons[m]; ok {
				m = icon
			}
			parts = append(parts, key.Render(m))
		}
		var ks []string
		for _, k := range st.keys {
			ks = append(ks, key.Render(k))
		}
		parts = append(parts, strings.Join(ks, faint.Render("/")))
		out = append(out, strings.Join(parts, " "))
	}
	return strings.Join(out, faint.Render("  or  "))
}

// ----- rows -----

type row struct {
	combos [][]string // keyboard combos, each as parts
	mouse  [][]string
	desc   string
	group  int
	search string
	order  int
}

var digitRe = regexp.MustCompile(`^[1-9]$`)

func buildRows(binds []bind) []row {
	// One row per action: its keys together (← and H, and the scroll wheel).
	byAction := map[string]*row{}
	var rows []*row
	// focus-workspace 1…9 and the like collapse into one row.
	ranges := map[string]*row{}
	for i, b := range binds {
		parts := keyParts(b.key)
		last := parts[len(parts)-1]
		if len(b.args) == 1 && digitRe.MatchString(b.args[0]) && digitRe.MatchString(last) && strings.Contains(b.action, "workspace") {
			tmpl := strings.Join(parts[:len(parts)-1], "+") + "|" + b.action
			if r, ok := ranges[tmpl]; ok {
				r.combos[0][len(r.combos[0])-1] = "1…9"
				continue
			}
			r := &row{combos: [][]string{parts}, desc: strings.TrimSuffix(describe(b), " "+b.args[0]) + " 1–9", group: classify(b), order: i}
			ranges[tmpl] = r
			rows = append(rows, r)
			continue
		}
		id := b.action + "\x00" + strings.Join(b.args, "\x00")
		r, ok := byAction[id]
		if !ok {
			r = &row{desc: describe(b), group: classify(b), order: i}
			byAction[id] = r
			rows = append(rows, r)
		}
		if b.title != "" && r.desc != describe(b) {
			r.desc = describe(b)
		}
		if strings.HasPrefix(b.key, "Wheel") || strings.Contains(b.key, "+Wheel") {
			r.mouse = append(r.mouse, parts)
		} else {
			r.combos = append(r.combos, parts)
		}
	}
	out := make([]row, 0, len(rows))
	for _, r := range rows {
		if len(r.combos) == 0 && len(r.mouse) > 0 {
			r.combos, r.mouse = r.mouse, nil
		}
		var keys []string
		for _, c := range append(append([][]string{}, r.combos...), r.mouse...) {
			keys = append(keys, strings.Join(c, " "))
		}
		r.search = strings.ToLower(r.desc + " " + groups[r.group].name + " " + strings.Join(keys, " "))
		out = append(out, *r)
	}
	sort.SliceStable(out, func(i, j int) bool {
		if out[i].group != out[j].group {
			return out[i].group < out[j].group
		}
		return out[i].order < out[j].order
	})
	return out
}

// ----- view -----

type model struct {
	rows   []row
	input  textinput.Model
	width  int
	height int
	scroll int
	source string
	err    string
}

var (
	faint = lipgloss.NewStyle().Foreground(lipgloss.Color("8"))
	plain = lipgloss.NewStyle()
)

func (m model) Init() tea.Cmd { return textinput.Blink }

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c":
			return m, tea.Quit
		case "esc":
			if m.input.Value() == "" {
				return m, tea.Quit
			}
			m.input.SetValue("")
			m.scroll = 0
			return m, nil
		case "up":
			m.scroll = max(0, m.scroll-1)
			return m, nil
		case "down":
			m.scroll++
			return m, nil
		case "pgup":
			m.scroll = max(0, m.scroll-10)
			return m, nil
		case "pgdown":
			m.scroll += 10
			return m, nil
		}
		var cmd tea.Cmd
		before := m.input.Value()
		m.input, cmd = m.input.Update(msg)
		if m.input.Value() != before {
			m.scroll = 0
		}
		return m, cmd
	}
	return m, nil
}

func (m model) visible() []row {
	terms := strings.Fields(strings.ToLower(m.input.Value()))
	var out []row
	for _, r := range m.rows {
		ok := true
		for _, t := range terms {
			if !strings.Contains(r.search, t) {
				ok = false
				break
			}
		}
		if ok {
			out = append(out, r)
		}
	}
	return out
}

// One group as a block of lines, keys aligned within it.
func renderGroup(g group, rows []row, width int) []string {
	head := lipgloss.NewStyle().Foreground(g.color).Bold(true).Render(g.icon + "  " + g.name)
	lines := []string{head}
	keyCells := make([]string, len(rows))
	keyW := 0
	for i, r := range rows {
		keyCells[i] = renderCombos(r.combos, g.color)
		keyW = max(keyW, lipgloss.Width(keyCells[i]))
	}
	keyW = min(keyW, width/2)
	for i, r := range rows {
		desc := r.desc
		if len(r.mouse) > 0 {
			// Also on the scroll wheel; the filter finds "scroll".
			desc += faint.Render("  \U000F037D")
		}
		cell := lipgloss.NewStyle().Width(keyW).Render(keyCells[i])
		line := "  " + cell + "  " + desc
		if lipgloss.Width(line) > width {
			// Long keys: the description on its own line, indented.
			lines = append(lines, "  "+keyCells[i], "  "+strings.Repeat(" ", min(keyW, 8))+"  "+desc)
			continue
		}
		lines = append(lines, line)
	}
	return lines
}

func (m model) View() string {
	if m.err != "" {
		return m.err + "\n"
	}
	// A margin on both sides, so the first column's icons do not touch the edge.
	const margin = 2
	pad := strings.Repeat(" ", margin)
	width := max(m.width-2*margin, 30)
	vis := m.visible()

	// Group blocks packed into columns, in order: the fewest columns that fit
	// the window height, as many as the width allows (each as wide as the
	// widest row, so the count follows the font and the content).
	room := max(1, m.height-5)
	maxCols := max(1, (width+2)/(naturalWidth(vis)+2))
	var cols [][]string
	var colW int
	for n := 1; n <= maxCols; n++ {
		colW = (width - 2*(n-1)) / n
		cols = pack(vis, colW, n)
		tallest := 0
		for _, c := range cols {
			tallest = max(tallest, len(c))
		}
		if tallest <= room {
			break
		}
	}
	var rendered []string
	for _, c := range cols {
		if len(c) == 0 {
			continue
		}
		rendered = append(rendered, lipgloss.NewStyle().Width(colW).Render(strings.Join(c, "\n")))
	}
	body := lipgloss.JoinHorizontal(lipgloss.Top, intersperse(rendered, "  ")...)
	if len(vis) == 0 {
		body = faint.Render(fmt.Sprintf("  No bind matches “%s”.", m.input.Value()))
	}

	// Scroll the body when it is taller than the window.
	bodyLines := strings.Split(body, "\n")
	maxScroll := max(0, len(bodyLines)-room)
	scroll := min(m.scroll, maxScroll)
	bodyLines = bodyLines[scroll:min(len(bodyLines), scroll+room)]
	for i, l := range bodyLines {
		bodyLines[i] = pad + l
	}

	top := pad + m.input.View()
	help := fmt.Sprintf("Esc clears, then closes · ↑↓ scroll · %d shortcuts · %s", len(vis), m.source)
	if maxScroll > 0 {
		help = fmt.Sprintf("%d/%d · ", scroll, maxScroll) + help
	}
	return "\n" + top + "\n\n" + strings.Join(bodyLines, "\n") + "\n" + faint.Render(pad+help)
}

// The widest line any visible group needs when nothing wraps.
func naturalWidth(vis []row) int {
	w := 20
	for gi, g := range groups {
		var rs []row
		for _, r := range vis {
			if r.group == gi {
				rs = append(rs, r)
			}
		}
		if len(rs) == 0 {
			continue
		}
		for _, l := range renderGroup(g, rs, 1000) {
			w = max(w, lipgloss.Width(l))
		}
	}
	return w
}

// The visible groups as blocks, laid into n columns of width colW.
func pack(vis []row, colW, n int) [][]string {
	var blocks [][]string
	for gi, g := range groups {
		var rs []row
		for _, r := range vis {
			if r.group == gi {
				rs = append(rs, r)
			}
		}
		if len(rs) == 0 {
			continue
		}
		blocks = append(blocks, renderGroup(g, rs, colW))
	}
	// The split of the blocks, in order, into at most n columns that keeps
	// the tallest column lowest (a block is its lines plus a blank above).
	h := make([]int, len(blocks)+1)
	for i, b := range blocks {
		h[i+1] = h[i] + len(b) + 1
	}
	height := func(i, j int) int { return h[j] - h[i] - 1 }
	const inf = 1 << 30
	best := make([][]int, n+1)
	cut := make([][]int, n+1)
	for k := range best {
		best[k] = make([]int, len(blocks)+1)
		cut[k] = make([]int, len(blocks)+1)
		for j := range best[k] {
			best[k][j] = inf
		}
	}
	best[0][0] = 0
	for k := 1; k <= n; k++ {
		for j := 0; j <= len(blocks); j++ {
			for i := 0; i <= j; i++ {
				if best[k-1][i] == inf {
					continue
				}
				col := 0
				if j > i {
					col = height(i, j)
				}
				if v := max(best[k-1][i], col); v < best[k][j] {
					best[k][j], cut[k][j] = v, i
				}
			}
		}
	}
	cols := make([][]string, n)
	j := len(blocks)
	for k := n; k >= 1; k-- {
		i := cut[k][j]
		for bi := i; bi < j; bi++ {
			if len(cols[k-1]) > 0 {
				cols[k-1] = append(cols[k-1], "")
			}
			cols[k-1] = append(cols[k-1], blocks[bi]...)
		}
		j = i
	}
	return cols
}

func intersperse(xs []string, sep string) []string {
	var out []string
	for i, x := range xs {
		if i > 0 {
			out = append(out, sep)
		}
		out = append(out, x)
	}
	return out
}

func configPath() string {
	if len(os.Args) > 1 {
		return os.Args[1]
	}
	if p := os.Getenv("NIRI_CONFIG"); p != "" {
		return p
	}
	dir := os.Getenv("XDG_CONFIG_HOME")
	if dir == "" {
		home, _ := os.UserHomeDir()
		dir = filepath.Join(home, ".config")
	}
	return filepath.Join(dir, "niri", "config.kdl")
}

func main() {
	path := configPath()
	m := model{source: strings.Replace(path, os.Getenv("HOME"), "~", 1)}
	data, err := os.ReadFile(path)
	if err != nil {
		m.err = "Cannot read the niri config: " + err.Error()
	} else {
		m.rows = buildRows(parse(string(data)))
	}
	if len(os.Args) > 2 && os.Args[2] == "--dump" {
		for _, r := range m.rows {
			var ks []string
			for _, c := range r.combos {
				ks = append(ks, strings.Join(c, "+"))
			}
			fmt.Printf("%-14s %-40s %s\n", groups[r.group].name, strings.Join(ks, " / "), r.desc)
		}
		return
	}
	ti := textinput.New()
	ti.Prompt = lipgloss.NewStyle().Foreground(lipgloss.Color("4")).Render("  ")
	ti.Placeholder = "type to filter: a word from the name, the key or the group"
	ti.Width = 70
	ti.Focus()
	m.input = ti
	if _, err := tea.NewProgram(m, tea.WithAltScreen()).Run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
