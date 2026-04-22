#!/usr/bin/env python3
# xwindow.py — título da janela focada, apenas no monitor correto
#
# Dependência: sudo pacman -S python-i3ipc
# Uso no config.ini:
#   exec     = ~/.config/polybar/scripts/xwindow.py DP-2
#   tail     = true
#   interval = 0

import sys
import i3ipc

TARGET_OUTPUT = sys.argv[1] if len(sys.argv) > 1 else None
if not TARGET_OUTPUT:
    sys.exit(1)

MAX_LEN = 50


def get_focused_output(conn):
    """
    Usa get_workspaces() em vez de get_tree() — retorna só a lista de
    workspaces, muito menor que a árvore inteira. O workspace focado
    contém o output (monitor) onde ele está.
    """
    for ws in conn.get_workspaces():
        if ws.focused:
            return ws.output
    return None


def on_window(conn, event):
    # Ignora o disparo com container=None (i3ipc dispara 2x por evento)
    if event.container is None:
        return

    # Verifica em qual output está o workspace focado — chamada leve
    output = get_focused_output(conn)

    if output != TARGET_OUTPUT:
        print("", flush=True)
        return

    title = getattr(event.container, "name", "") or ""
    print(title[:MAX_LEN], flush=True)


def on_workspace(conn, event):
    # Troca de workspace: verifica o output e limpa ou mantém o título
    output = get_focused_output(conn)
    if output != TARGET_OUTPUT:
        print("", flush=True)
        return

    # Workspace focado é deste monitor — pega o título via get_tree()
    # (get_workspaces não tem título da janela focada dentro do workspace)
    try:
        focused = conn.get_tree().find_focused()
        title = getattr(focused, "name", "") or ""
        print(title[:MAX_LEN], flush=True)
    except Exception:
        print("", flush=True)


def main():
    conn = i3ipc.Connection()

    # Estado inicial
    output = get_focused_output(conn)
    if output == TARGET_OUTPUT:
        try:
            focused = conn.get_tree().find_focused()
            title = getattr(focused, "name", "") or "" if focused else ""
            print(title[:MAX_LEN], flush=True)
        except Exception:
            print("", flush=True)
    else:
        print("", flush=True)

    conn.on(i3ipc.Event.WINDOW_FOCUS,    on_window)
    conn.on(i3ipc.Event.WINDOW_TITLE,    on_window)
    conn.on(i3ipc.Event.WINDOW_CLOSE,    on_window)
    conn.on(i3ipc.Event.WORKSPACE_FOCUS, on_workspace)

    conn.main()


if __name__ == "__main__":
    main()
