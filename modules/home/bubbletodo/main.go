package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/charmbracelet/bubbles/textinput"
	"github.com/charmbracelet/bubbles/viewport"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

const defaultEndpoint = "https://engine.valolink.fi/api/todos/quick"

// ----- messages -----

type submitResultMsg struct {
	id      int
	content string
	title   string // server-echoed content, if any
	err     error
}

type histItem struct {
	id      int
	content string
	done    bool
	err     bool
}

// ----- model -----

type model struct {
	// styles (ANSI-indexed so the terminal theme rules)
	cursorSt lipgloss.Style
	outer    lipgloss.Style
	help     lipgloss.Style
	lineOk   lipgloss.Style
	lineErr  lipgloss.Style
	linePend lipgloss.Style
	statusOk lipgloss.Style
	statusEr lipgloss.Style

	vp    viewport.Model
	input textinput.Model

	history  []histItem // newest first
	status   string     // transient status/error line
	cmdID    int
	endpoint string
	apiKey   string
	keyErr   string
	ready    bool
}

func initialModel() model {
	faint := lipgloss.Color("8")
	green := lipgloss.Color("2")
	red := lipgloss.Color("1")

	ti := textinput.New()
	ti.Prompt = ""
	ti.Placeholder = "add a todo…"
	ti.Focus()

	endpoint := os.Getenv("TODO_ENDPOINT")
	if endpoint == "" {
		endpoint = defaultEndpoint
	}

	key, keyErr := loadAPIKey()

	return model{
		cursorSt: lipgloss.NewStyle().Reverse(true),
		outer:    lipgloss.NewStyle().Padding(1, 2).Margin(0, 1),
		help:     lipgloss.NewStyle().Foreground(faint),
		lineOk:   lipgloss.NewStyle().Foreground(green),
		lineErr:  lipgloss.NewStyle().Foreground(red),
		linePend: lipgloss.NewStyle().Foreground(faint),
		statusOk: lipgloss.NewStyle().Foreground(green),
		statusEr: lipgloss.NewStyle().Foreground(red),
		vp:       viewport.New(80, 20),
		input:    ti,
		history:  []histItem{},
		endpoint: endpoint,
		apiKey:   key,
		keyErr:   keyErr,
	}
}

func (m model) Init() tea.Cmd { return textinput.Blink }

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		fw, fh := m.outer.GetFrameSize()
		innerW := max(20, msg.Width-fw)
		innerH := max(8, msg.Height-fh)
		const reserved = 5
		m.vp.Width = innerW
		m.vp.Height = max(3, innerH-reserved)
		m.ready = true
		return m, nil

	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c", "esc":
			return m, tea.Quit
		case "enter":
			content := strings.TrimSpace(m.input.Value())
			if content == "" {
				return m, nil
			}
			if m.apiKey == "" {
				m.status = m.statusEr.Render("no API key: " + m.keyErr)
				return m, nil
			}
			m.cmdID++
			id := m.cmdID
			m.prependItem(histItem{id: id, content: content, done: false})
			m.input.SetValue("")
			m.status = ""
			return m, submitTodo(m.endpoint, m.apiKey, content, id)
		}
	}

	var cmd tea.Cmd
	m.input, cmd = m.input.Update(msg)

	switch msg := msg.(type) {
	case submitResultMsg:
		for i := range m.history {
			if m.history[i].id != msg.id {
				continue
			}
			if msg.err != nil {
				m.history[i].done = true
				m.history[i].err = true
				m.status = m.statusEr.Render("error: " + sanitize(msg.err.Error()))
			} else {
				m.history[i].done = true
				m.history[i].err = false
				if msg.title != "" {
					m.history[i].content = msg.title
				}
				m.status = m.statusOk.Render("added ✓")
			}
			break
		}
	}

	m.renderHistory()
	return m, cmd
}

func (m model) View() string {
	if !m.ready {
		return "loading…"
	}
	help := m.help.Render("󰌑 add  󱊷 quit")
	footer := help
	if m.status != "" {
		footer = m.status + "   " + help
	}

	var body strings.Builder
	body.WriteString("\n\n")
	body.WriteString(m.vp.View())
	body.WriteString("\n\n")
	body.WriteString(renderInputLine(m))
	body.WriteString("\n")
	body.WriteString(footer)

	return m.outer.Render(body.String())
}

func (m *model) renderHistory() {
	var b strings.Builder
	for i, it := range m.history {
		if i > 0 {
			b.WriteString("\n")
		}
		switch {
		case !it.done:
			b.WriteString(m.linePend.Render("… " + it.content))
		case it.err:
			b.WriteString(m.lineErr.Render("✗ " + it.content))
		default:
			b.WriteString(m.lineOk.Render("✓ " + it.content))
		}
	}
	m.vp.SetContent(b.String())
}

func (m *model) prependItem(it histItem) {
	m.history = append([]histItem{it}, m.history...)
}

// ----- api key -----

// loadAPIKey resolves the key from $TODO_API_KEY, else
// $XDG_CONFIG_HOME/bubbletodo/apikey (default ~/.config/bubbletodo/apikey).
func loadAPIKey() (string, string) {
	if k := strings.TrimSpace(os.Getenv("TODO_API_KEY")); k != "" {
		return k, ""
	}
	dir := os.Getenv("XDG_CONFIG_HOME")
	if dir == "" {
		home, err := os.UserHomeDir()
		if err != nil {
			return "", "cannot find home dir"
		}
		dir = filepath.Join(home, ".config")
	}
	path := filepath.Join(dir, "bubbletodo", "apikey")
	data, err := os.ReadFile(path)
	if err != nil {
		return "", "set $TODO_API_KEY or write " + path
	}
	k := strings.TrimSpace(string(data))
	if k == "" {
		return "", path + " is empty"
	}
	return k, ""
}

// ----- http -----

func submitTodo(endpoint, apiKey, content string, id int) tea.Cmd {
	return func() tea.Msg {
		title, err := postTodo(endpoint, apiKey, content, 8*time.Second)
		return submitResultMsg{id: id, content: content, title: title, err: err}
	}
}

func postTodo(endpoint, apiKey, content string, timeout time.Duration) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	payload, err := json.Marshal(map[string]string{"content": content})
	if err != nil {
		return "", err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, endpoint, bytes.NewReader(payload))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("x-api-key", apiKey)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var body bytes.Buffer
	_, _ = body.ReadFrom(resp.Body)

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		msg := strings.TrimSpace(body.String())
		if msg == "" {
			msg = resp.Status
		}
		return "", fmt.Errorf("%d: %s", resp.StatusCode, oneLine(msg))
	}

	var parsed struct {
		Content string `json:"content"`
	}
	if json.Unmarshal(body.Bytes(), &parsed) == nil && parsed.Content != "" {
		return parsed.Content, nil
	}
	return "", nil
}

// ----- helpers -----

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

// renderInputLine prints one line with a prompt, the text, and a block cursor.
func renderInputLine(m model) string {
	const prompt = "> "
	val := m.input.Value()
	cur := m.input.Position()

	left, right := runeSplit(val, cur)

	var under, rest string
	if right == "" {
		under = " "
	} else {
		_, size := utf8.DecodeRuneInString(right)
		under = right[:size]
		rest = right[size:]
	}
	return prompt + left + m.cursorSt.Render(under) + rest
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
