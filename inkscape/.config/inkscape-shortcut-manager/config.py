import subprocess
from pathlib import Path

MACROS = Path('~/.config/inkscape-shortcut-manager/macros.tex').expanduser()


def open_editor(filename):
    # Blocks until the frame is closed. Emacs recognises the frame by its
    # name and sets it up (see `my/inkscape-latex-popup-setup').
    subprocess.run([
        'emacsclient', '-c',
        '-F', '((name . "inkscape-latex") (visibility . nil)'
              ' (width . 60) (height . 4))',
        filename,
    ])


def latex_document(latex):
    macros = MACROS.read_text() if MACROS.exists() else ''
    return r"""
        \documentclass[12pt,border=12pt]{standalone}
        \usepackage[utf8]{inputenc}
        \usepackage[T1]{fontenc}
        \usepackage{textcomp}
        \usepackage{amsmath, amssymb}
        """ + macros + r"""
        \begin{document}
    """ + latex + r"\end{document}"


config = {
    'rofi_theme': None,
    # The font only matters inside Inkscape: on save the text is typeset by
    # LaTeX. Monospace keeps the source readable while drawing. Inkscape 1.4
    # reads the size as px and the template counts in mm, so 13 comes out
    # 3.4 mm high, about the size of the 10pt text LaTeX will put there.
    'font': 'monospace',
    'font_size': 13,
    'open_editor': open_editor,
    'latex_document': latex_document,
}
