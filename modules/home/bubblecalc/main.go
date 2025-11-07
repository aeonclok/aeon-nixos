package main

import (
	"bytes"
	"context"
	"fmt"
	"os/exec"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/charmbracelet/bubbles/textinput"
	"github.com/charmbracelet/bubbles/viewport"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"

	"github.com/alecthomas/chroma/formatters"
	"github.com/alecthomas/chroma/lexers"
	"github.com/alecthomas/chroma/styles"
)

type calcResultMsg struct {
	id   int
	expr string
	out  string
	err  error
}
type previewTickMsg struct {
	expr string
	id   int
}
type previewResultMsg struct {
	expr, out string
	err       error
	id        int
}

type histItem struct {
	id   int
	expr string
	out  string
	done bool
}

type model struct {
	// styles (ANSI-indexed so your terminal theme rules)
	cursorSt lipgloss.Style
	outer    lipgloss.Style
	header   lipgloss.Style
	help     lipgloss.Style
	lineExpr lipgloss.Style
	lineOut  lipgloss.Style
	statusOk lipgloss.Style
	statusEr lipgloss.Style
	hlInput  lipgloss.Style

	// widgets
	vp    viewport.Model
	input textinput.Model

	// state
	history         []histItem // newest first
	preview         string     // preview result (green)
	status          string     // transient status/errors (red for errors)
	previewID       int
	cmdID           int
	recallIndex     int
	previewDebounce time.Duration
	ready           bool
}

func initialModel() model {
	faint := lipgloss.Color("8")
	green := lipgloss.Color("2")
	red := lipgloss.Color("1")
	title := lipgloss.Color("7")

	cursorSt := lipgloss.NewStyle().Reverse(true)
	outer := lipgloss.NewStyle().Padding(1, 2).Margin(0, 1)
	header := lipgloss.NewStyle().Bold(true).Foreground(title)
	help := lipgloss.NewStyle().Foreground(faint)
	lineExpr := lipgloss.NewStyle().Foreground(green)
	lineOut := lipgloss.NewStyle()
	statusOk := lipgloss.NewStyle().Foreground(green)
	statusEr := lipgloss.NewStyle().Foreground(red)
	ti := textinput.New()
	ti.Prompt = ""
	ti.Placeholder = ""
	ti.Focus()

	vp := viewport.New(80, 20)

	return model{
		outer: outer, header: header, help: help,
		lineExpr: lineExpr, lineOut: lineOut,
		statusOk: statusOk, statusEr: statusEr,
		cursorSt: cursorSt,
		vp:       vp, input: ti,
		history:         []histItem{},
		recallIndex:     -1,
		previewDebounce: 180 * time.Millisecond,
	}
}

func (m model) Init() tea.Cmd { return textinput.Blink }

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		fw, fh := m.outer.GetFrameSize()
		innerW := max(20, msg.Width-fw)
		innerH := max(8, msg.Height-fh)
		// header + blank + highlighted input + input + footer + blanks
		const reserved = 5
		m.vp.Width = innerW
		m.vp.Height = max(3, innerH-reserved)
		m.ready = true
		return m, nil

	case tea.KeyMsg:
		switch msg.String() {
		case "up":
			if expr, ok := m.recallUp(); ok {
				m.input.SetValue(expr)
				m.input.CursorEnd()
				// schedule preview for the recalled expr
				m.previewID++
				id := m.previewID
				val := strings.TrimSpace(expr)
				if val == "" {
					m.preview = ""
				}
				return m, tea.Tick(m.previewDebounce, func(time.Time) tea.Msg {
					return previewTickMsg{expr: val, id: id}
				})
			}
			return m, nil
		case "down":
			if expr, ok := m.recallDown(); ok {
				m.input.SetValue(expr) // may be ""
				m.input.CursorEnd()
				m.previewID++
				id := m.previewID
				val := strings.TrimSpace(expr)
				if val == "" {
					m.preview = ""
				}
				return m, tea.Tick(m.previewDebounce, func(time.Time) tea.Msg {
					return previewTickMsg{expr: val, id: id}
				})
			}
			return m, nil
		case "ctrl+c", "q":
			return m, tea.Quit
		case "esc":
			if m.input.Value() != "" {
				m.input.SetValue("")
				m.preview, m.status = "", ""
				m.recallReset()
			} else {
				m.history = nil
				m.preview, m.status = "", ""
				m.recallReset()
			}
			return m, nil
		case "enter":
			expr := strings.TrimSpace(m.input.Value())
			if expr == "" {
				return m, nil
			}
			// Add a pending item
			m.cmdID++
			id := m.cmdID
			m.prependItem(histItem{id: id, expr: expr, done: false})
			m.input.SetValue("")
			m.preview, m.status = "", ""
			m.recallReset()
			return m, runCalcWithCmdID(expr, id)
		}
	}

	// text input + behavior tweaks
	var cmd tea.Cmd
	old := m.input.Value()
	m.input, cmd = m.input.Update(msg)

	if m.input.Value() != old {
		v := m.input.Value()

		// If the user started with an operator, prepend last result
		if old == "" && startsWithOp(v) {
			if last := m.lastResult(); last != "" {
				v = last + v
			}
		}

		newVal, newPos := beautifyWithCursor(v, m.input.Position())
		if newVal != v {
			m.input.SetValue(newVal)
			// direct set in runes
			m.input.SetCursor(newPos)
		} else {
			// value didn’t change, but we might still need to adjust if the user typed
			// something that changed rune index; keep cursor as-is.
		}

		// schedule debounced preview
		m.previewID++
		id := m.previewID
		val := strings.TrimSpace(m.input.Value())
		if val == "" {
			m.preview = ""
		}
		return m, tea.Batch(
			cmd,
			tea.Tick(m.previewDebounce, func(time.Time) tea.Msg {
				return previewTickMsg{expr: val, id: id}
			}),
		)
	}

	// background
	switch msg := msg.(type) {
	case calcResultMsg:
		// On error: remove the pending entry and show status (don't store in history)
		if msg.err != nil {
			m.removeItem(msg.id)
			m.status = m.statusEr.Render("error: " + sanitize(msg.err.Error()))
			break
		}
		// success: finalize the pending entry with output
		for i := range m.history {
			if m.history[i].id == msg.id {
				m.history[i].done = true
				m.history[i].expr = msg.expr
				m.history[i].out = strings.TrimSpace(msg.out)
				m.status = "" // clear any previous error
				break
			}
		}
	case previewTickMsg:
		if msg.id == m.previewID && msg.expr != "" {
			return m, runCalcPreview(msg.expr, msg.id)
		}
	case previewResultMsg:
		if msg.id == m.previewID {
			if msg.err == nil {
				out := oneLine(strings.TrimSpace(msg.out))
				if out != "" {
					m.preview = m.lineOut.Render("≈ " + out)
				} else {
					m.preview = ""
				}
			} else {
				m.preview = "" // hide preview on errors
			}
		}
	}

	// render history
	var b strings.Builder
	for i, it := range m.history {
		if i > 0 {
			b.WriteString("\n\n")
		}
		if !it.done {
			b.WriteString(m.lineExpr.Render("• " + highlight(it.expr) + " …"))
			continue
		}
		out := it.out
		if out == "" {
			out = "(no output)"
		}
		b.WriteString(m.lineExpr.Render("= " + highlight(it.expr)))
		b.WriteString("\n  ")
		b.WriteString(m.lineOut.Render(out))
	}
	m.vp.SetContent(b.String())

	return m, cmd
}

func (m model) View() string {
	if !m.ready {
		return "loading…"
	}
	help := m.help.Render("󰌑 evaluate 󱊷 clear  ↑/↓ recall  q quit")
	footerLeft := help
	if m.preview != "" {
		footerLeft = m.preview + "   " + help
	}
	if m.status != "" {
		footerLeft = m.status + "   " + help
	}

	var body strings.Builder
	body.WriteString("\n\n")
	body.WriteString(m.vp.View())
	body.WriteString("\n\n")
	body.WriteString(renderInputLine(m)) // << single, inline highlighted input
	body.WriteString("\n")
	body.WriteString(footerLeft)

	return m.outer.Render(body.String())
}

// ----- history helpers -----

func (m *model) prependItem(it histItem) {
	m.history = append([]histItem{it}, m.history...)
}

func (m *model) removeItem(id int) {
	for i := range m.history {
		if m.history[i].id == id {
			m.history = append(m.history[:i], m.history[i+1:]...)
			return
		}
	}
}

func (m *model) lastResult() string {
	for _, it := range m.history {
		if it.done && strings.TrimSpace(it.out) != "" {
			// return the MOST RECENT finished result
			return oneLine(strings.TrimSpace(it.out))
		}
	}
	return ""
}

// ----- calc exec + helpers -----

func runCalcWithCmdID(expr string, id int) tea.Cmd {
	return func() tea.Msg {
		out, err := callCalc(expr, 3*time.Second)
		return calcResultMsg{id: id, expr: expr, out: out, err: err}
	}
}

func runCalcPreview(expr string, id int) tea.Cmd {
	return func() tea.Msg {
		out, err := callCalc(expr, 750*time.Millisecond)
		return previewResultMsg{expr: expr, out: out, err: err, id: id}
	}
}

func callCalc(expr string, timeout time.Duration) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	cmd := exec.CommandContext(ctx, "calc", "-qps")
	cmd.Stdin = bytes.NewBufferString(expr + "\n")
	var out, stderr bytes.Buffer
	cmd.Stdout, cmd.Stderr = &out, &stderr
	err := cmd.Run()
	if ctx.Err() == context.DeadlineExceeded {
		err = fmt.Errorf("timeout running calc")
	}
	if err != nil {
		msg := strings.TrimSpace(stderr.String())
		if msg == "" {
			msg = err.Error()
		}
		return "", fmt.Errorf(msg)
	}
	return out.String(), nil
}

func sanitize(s string) string {
	return strings.TrimSpace(strings.ReplaceAll(s, "\r", ""))
}

func oneLine(s string) string {
	if i := strings.IndexByte(s, '\n'); i >= 0 {
		return strings.TrimSpace(s[:i])
	}
	return strings.TrimSpace(s)
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func highlight(src string) string {
	if strings.TrimSpace(src) == "" {
		return src
	}
	lexer := lexers.Get("bash")
	if lexer == nil {
		lexer = lexers.Fallback
	}
	style := styles.Get("friendly")
	if style == nil {
		style = styles.Fallback
	}
	formatter := formatters.Get("terminal") // 8/16-color ANSI -> uses your theme
	itr, err := lexer.Tokenise(nil, src)
	if err != nil {
		return src
	}
	var b strings.Builder
	if err := formatter.Format(&b, style, itr); err != nil {
		return src
	}
	return b.String()
}

func startsWithOp(s string) bool {
	if s == "" {
		return false
	}
	switch s[0] {
	case '+', '-', '*', '/', '^', '%':
		return true
	default:
		return false
	}
}

func (m *model) recallList() []string {
	out := make([]string, 0, len(m.history))
	for _, it := range m.history {
		if it.done && strings.TrimSpace(it.expr) != "" {
			out = append(out, it.expr) // newest first
		}
	}
	return out
}

func (m *model) recallReset() { m.recallIndex = -1 }

func (m *model) recallUp() (string, bool) {
	lst := m.recallList()
	if len(lst) == 0 {
		return "", false
	}
	if m.recallIndex < len(lst)-1 {
		m.recallIndex++
	}
	return lst[m.recallIndex], true
}

func (m *model) recallDown() (string, bool) {
	lst := m.recallList()
	if len(lst) == 0 {
		return "", false
	}
	if m.recallIndex <= 0 {
		m.recallIndex = -1
		return "", true // clear input when we move "below" newest
	}
	m.recallIndex--
	return lst[m.recallIndex], true
}

// renderInputLine prints one line with a prompt, syntax-highlighted text, and a block cursor.
func renderInputLine(m model) string {
	const prompt = "> "
	val := m.input.Value()

	// caret position in RUNES (not bytes)
	cur := m.input.Position()

	left, right := runeSplit(val, cur)
	hlLeft := highlight(left)
	hlRight := highlight(right)

	// character under cursor (or a space at end of line)
	var under string
	if right == "" {
		under = " "
	} else {
		_, size := utf8.DecodeRuneInString(right)
		under = right[:size]
		hlRight = highlight(right[size:])
	}
	return prompt + hlLeft + m.cursorSt.Render(under) + hlRight
}

// beautify adds spaces around operators/parens and collapses multiple spaces.
// It is idempotent: beautify(beautify(s)) == beautify(s).
func beautify(s string) string {
	var b strings.Builder
	b.Grow(len(s) * 2)

	isOp := func(r rune) bool {
		switch r {
		case '+', '-', '*', '/', '^', '%', '=', '(', ')', ',', ':':
			return true
		default:
			return false
		}
	}

	prevSpace := false
	for _, r := range s {
		if isOp(r) {
			if !prevSpace {
				b.WriteByte(' ')
			}
			b.WriteRune(r)
			b.WriteByte(' ')
			prevSpace = true
			continue
		}
		if r == ' ' || r == '\t' {
			if !prevSpace {
				b.WriteByte(' ')
				prevSpace = true
			}
			continue
		}
		b.WriteRune(r)
		prevSpace = false
	}
	out := strings.TrimSpace(b.String())
	// collapse any accidental doubles (paranoia after user pastes)
	for strings.Contains(out, "  ") {
		out = strings.ReplaceAll(out, "  ", " ")
	}
	return out
}

// beautifyWithCursor returns the beautified string AND where the cursor
// should land (in runes). We compute newPos by formatting only the prefix.
func beautifyWithCursor(s string, posRunes int) (string, int) {
	// left prefix by runes
	left, _ := runeSplit(s, posRunes)
	leftFmt := beautify(left)
	allFmt := beautify(s)
	// cursor goes right after the formatted prefix
	newPos := utf8.RuneCountInString(leftFmt)
	// clamp
	totalRunes := utf8.RuneCountInString(allFmt)
	if newPos < 0 {
		newPos = 0
	}
	if newPos > totalRunes {
		newPos = totalRunes
	}
	return allFmt, newPos
}

// runeSplit returns s[:cursorRunes] and s[cursorRunes:], counting runes.
func runeSplit(s string, cursorRunes int) (string, string) {
	if cursorRunes <= 0 {
		return "", s
	}
	i := 0
	for pos := range s {
		if i == cursorRunes {
			return s[:pos], s[pos:]
		}
		i++
	}
	return s, ""
}

func main() {
	if err := tea.NewProgram(initialModel(), tea.WithAltScreen()).Start(); err != nil {
		fmt.Println("error:", err)
	}
}
