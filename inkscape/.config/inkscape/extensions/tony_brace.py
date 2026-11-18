#!/usr/bin/env python3
import math

import inkex
from inkex import PathElement

AMPLITUDE = "2.5mm"


class Brace(inkex.EffectExtension):
    def effect(self):
        amplitude = self.svg.viewport_to_unit(AMPLITUDE)
        for node in self.svg.selection.filter(PathElement).values():
            self.brace(node, amplitude)

    def brace(self, node, amplitude):
        ends = node.get("data-brace")
        if ends:
            x1, y1, x0, y0 = map(float, ends.split())
        else:
            points = list(node.path.end_points)
            (x0, y0), (x1, y1) = tuple(points[0]), tuple(points[-1])
        length = math.hypot(x1 - x0, y1 - y0)
        if length == 0:
            return
        t = node.composed_transform()
        scale = math.sqrt(abs(t.a * t.d - t.b * t.c)) or 1
        amp = min(amplitude / scale, length / 3)
        h = amp / 2
        ux, uy = (x1 - x0) / length, (y1 - y0) / length
        # Left of the direction of travel, with SVG's y axis pointing down.
        nx, ny = uy, -ux

        def p(along, out):
            return f"{x0 + ux * along + nx * out:.4f},{y0 + uy * along + ny * out:.4f}"

        m = length / 2
        node.path = (
            f"M {p(0, 0)} Q {p(0, h)} {p(h, h)} L {p(m - h, h)} "
            f"Q {p(m, h)} {p(m, amp)} Q {p(m, h)} {p(m + h, h)} "
            f"L {p(length - h, h)} Q {p(length, h)} {p(length, 0)}"
        )
        node.set("data-brace", f"{x0} {y0} {x1} {y1}")
        node.set("sodipodi:nodetypes", None)
        for key in ("marker-start", "marker-mid", "marker-end"):
            node.style[key] = "none"
        node.style["fill"] = "none"
        node.style["stroke-linejoin"] = "round"
        node.style["stroke-linecap"] = "round"


if __name__ == "__main__":
    Brace().run()
