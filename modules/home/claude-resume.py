"""cr: find and resume a Claude Code session with fzf.

Every session under ~/.claude/projects, newest first: its name (/rename, else Claude Code's own title, else the
first prompt), project, age, and your prompts, all searchable. The preview shows what the session covered.
Enter resumes it in this pane; a session already open in a tmux window is switched to instead. Ctrl-T resumes it
in a new tmux window. The index is cached per transcript (path, size, mtime) in ~/.cache/claude-resume.
  cr [query]          pick and resume
  cr --popup [query]  the same from a tmux popup (prefix+R): Enter opens a new window instead of this pane
  cr --preview ID     the preview text (used by fzf)
"""
import json, os, re, shlex, subprocess, sys, time

PROJECTS = os.path.expanduser("~/.claude/projects")
CACHE = os.path.expanduser("~/.cache/claude-resume/index.json")
CLAUDE = ["claude", "--dangerously-skip-permissions", "--resume"]
NOISE = re.compile(r"^\s*(<(command-|local-command|system-reminder|bash-|task-notification|user-prompt-submit)|\[Request interrupted)", re.I)


def text_of(content):
    if isinstance(content, str): return content
    if isinstance(content, list):
        return "\n".join(c.get("text", "") for c in content if isinstance(c, dict) and c.get("type") == "text")
    return ""


def scan(path):
    """One transcript -> a summary record (the expensive part; cached)."""
    s = {"id": os.path.basename(path)[:-6], "custom": None, "ai": None, "cwd": None, "branch": None,
         "first": None, "prompts": [], "n": 0, "start": None, "end": None, "last_reply": ""}
    with open(path, encoding="utf-8", errors="replace") as f:
        for line in f:
            if '"custom-title"' in line or '"ai-title"' in line:
                try: d = json.loads(line)
                except ValueError: continue
                if d.get("type") == "custom-title": s["custom"] = d.get("customTitle") or s["custom"]
                elif d.get("type") == "ai-title": s["ai"] = d.get("aiTitle") or s["ai"]
                continue
            if '"type":"user"' not in line and '"type":"assistant"' not in line: continue
            try: d = json.loads(line)
            except ValueError: continue
            if d.get("isSidechain") or d.get("isMeta"): continue
            ts = d.get("timestamp")
            if ts: s["start"] = s["start"] or ts; s["end"] = ts
            s["cwd"] = s["cwd"] or d.get("cwd"); s["branch"] = d.get("gitBranch") or s["branch"]
            msg = d.get("message") or {}
            if d.get("type") == "user":
                if d.get("toolUseResult") is not None or d.get("turnOrigin") not in (None, "human"): continue
                t = text_of(msg.get("content")).strip()
                if not t or NOISE.match(t): continue
                s["n"] += 1; s["first"] = s["first"] or t
                s["prompts"].append(t[:400]); s["prompts"] = s["prompts"][-40:]
            else:
                t = text_of(msg.get("content")).strip()
                if t: s["last_reply"] = t[:1500]
    return s


def index():
    try: cache = json.load(open(CACHE, encoding="utf-8"))
    except (OSError, ValueError): cache = {}
    out, fresh = [], {}
    for d in os.listdir(PROJECTS):
        pd = os.path.join(PROJECTS, d)
        if not os.path.isdir(pd): continue
        for fn in os.listdir(pd):
            if not fn.endswith(".jsonl"): continue
            p = os.path.join(pd, fn); st = os.stat(p); key = f"{st.st_size}:{int(st.st_mtime)}"
            rec = cache.get(p)
            if not rec or rec.get("key") != key:
                rec = scan(p); rec["key"] = key
            rec["mtime"] = st.st_mtime; fresh[p] = rec
            if rec["n"]: out.append(rec)
    os.makedirs(os.path.dirname(CACHE), exist_ok=True)
    tmp = CACHE + ".tmp"; json.dump(fresh, open(tmp, "w", encoding="utf-8")); os.replace(tmp, CACHE)
    return sorted(out, key=lambda r: -r["mtime"])


def name(r):
    return r["custom"] or r["ai"] or re.sub(r"\s+", " ", r["first"] or "")[:60]


def open_windows():
    """Session id -> tmux window for sessions running in tmux: from 'claude --resume ID' in the process list,
    and from pane titles that match a session name (Claude Code writes its name to the pane title)."""
    by_id, by_title = {}, {}
    try:
        panes = subprocess.run(["tmux", "list-panes", "-a", "-F",
                                "#{pane_pid}\t#{session_name}:#{window_index}\t#{pane_current_command}\t#{pane_title}"],
                               capture_output=True, text=True, timeout=3).stdout.splitlines()
    except (OSError, subprocess.SubprocessError): return by_id, by_title
    for line in panes:
        pid, win, cmd, title = (line.split("\t") + ["", "", ""])[:4]
        if cmd != "claude": continue      # a pane back at the shell keeps the old title
        by_title.setdefault(re.sub(r"^[^\w]+\s", "", title).strip(), win)
        try:   # the pane's shell -> its claude child
            for c in open(f"/proc/{pid}/task/{pid}/children").read().split():
                args = open(f"/proc/{c}/cmdline", "rb").read().split(b"\0")
                if b"--resume" in args:
                    i = args.index(b"--resume")
                    if i + 1 < len(args) and args[i + 1]: by_id[args[i + 1].decode()] = win
        except OSError: pass
    return by_id, by_title


def window_of(r, wins):
    by_id, by_title = wins
    return by_id.get(r["id"]) or (by_title.get(name(r)) if r["mtime"] > time.time() - 30 * 86400 else None)


def ago(t):
    s = time.time() - t
    return f"{int(s // 60)}m" if s < 3600 else f"{int(s // 3600)}h" if s < 86400 else f"{int(s // 86400)}d"


def short_cwd(c):
    return (c or "?").replace(os.path.expanduser("~"), "~").replace("~/valolink/", "")


def preview(sid):
    recs = {r["id"]: r for r in json.load(open(CACHE, encoding="utf-8")).values()}
    r = recs.get(sid)
    if not r: print("?"); return
    B, D, X = "\033[1m", "\033[2m", "\033[0m"
    win = window_of(r, open_windows())
    print(f"{B}{name(r)}{X}")
    if r["custom"] and r["ai"] and r["ai"] != r["custom"]: print(f"{D}Claude Code's title: {r['ai']}{X}")
    print(f"{short_cwd(r['cwd'])}{'  · ' + r['branch'] if r.get('branch') else ''}  ·  {r['n']} prompts  ·  "
          f"{(r['start'] or '')[:10]} → {(r['end'] or '')[:16].replace('T', ' ')} UTC")
    if win: print(f"\033[35m● open in tmux window {win}{X}")
    print(f"{D}{r['id']}{X}\n\n{B}First prompt{X}\n{r['first'][:700]}\n")
    last = [p for p in r["prompts"][-6:] if p != r["first"]]
    if last:
        print(f"{B}Latest prompts{X}")
        for p in last: print("• " + re.sub(r"\s+", " ", p)[:220])
        print()
    if r["last_reply"]:
        print(f"{B}Last reply{X}\n{r['last_reply'][:900]}")


def main():
    args = sys.argv[1:]
    if args[:1] == ["--preview"]: return preview(args[1])
    popup = args[:1] == ["--popup"]; args = args[1:] if popup else args
    recs = index(); wins = open_windows()
    lines = []
    for r in recs:
        win = window_of(r, wins)
        mark = "\033[35m●\033[0m" if win else " "
        search = " · ".join(re.sub(r"\s+", " ", p)[:160] for p in r["prompts"])
        shown = f"{mark} {ago(r['mtime']):>4}  \033[34m{short_cwd(r['cwd'])[:14]:<14}\033[0m  {name(r)}"
        lines.append(f"{shown}\t{r['id']}\t{r['cwd'] or ''}\t{win or ''}\t\033[2m{search}\033[0m")
    me = shlex.quote(os.path.abspath(sys.argv[0]))
    fzf = subprocess.run(
        ["fzf", "--ansi", "--delimiter", "\t", "--with-nth", "1,5", "--nth", "1,2", "--no-sort", "--tiebreak", "index",
         "--expect", "ctrl-t", "--query", " ".join(args), "--prompt", "session> ", "--height", "100%", "--reverse",
         "--header", "Enter: go to its window, or resume in a new one" if popup else
                     "Enter: resume here (or go to its open window) · Ctrl-T: new tmux window",
         "--preview", f"{me} --preview {{2}}", "--preview-window", "down,55%,wrap"],
        input="\n".join(lines), capture_output=False, stdout=subprocess.PIPE, text=True)
    out = fzf.stdout.splitlines()
    if fzf.returncode != 0 or len(out) < 2: return
    key, pick = out[0], out[1].split("\t")
    sid, cwd, win = pick[1], pick[2], pick[3]
    if win and key != "ctrl-t":
        subprocess.run(["tmux", "switch-client", "-t", win]); subprocess.run(["tmux", "select-window", "-t", win]); return
    cwd = cwd if os.path.isdir(cwd) else os.getcwd()
    if (key == "ctrl-t" or popup) and os.environ.get("TMUX"):
        subprocess.run(["tmux", "new-window", "-c", cwd, shlex.join(CLAUDE + [sid])]); return
    os.chdir(cwd); os.execvp(CLAUDE[0], CLAUDE + [sid])


if __name__ == "__main__":
    main()
