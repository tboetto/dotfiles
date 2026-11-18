#!/usr/bin/env python3
import math

import inkex
from inkex import Group, PathElement, TextElement

TICK = "1.2mm"
GAP = "1.2mm"
FONT = "3.4mm"
LABELS = False


class Axis(inkex.EffectExtension):
    def effect(self):
        for node in list(self.svg.selection.filter(PathElement).values()):
            self.axis(node)

    def grid_spacing(self):
        grid = self.svg.namedview.findone("inkscape:grid")
        if grid is not None and grid.get("spacingx"):
            return float(grid.get("spacingx"))
        return self.svg.viewport_to_unit("10mm")

    def axis(self, node):
        points = [tuple(p) for p in node.path.end_points]
        if len(points) < 2:
            return
        (sx, sy), (ex, ey) = points[0], points[-1]
        zx, zy = points[1] if len(points) > 2 else points[0]
        length = math.hypot(ex - sx, ey - sy)
        if length == 0:
            return
        t = node.composed_transform()
        scale = math.sqrt(abs(t.a * t.d - t.b * t.c)) or 1
        spacing = self.grid_spacing()
        tick = self.svg.viewport_to_unit(TICK) / scale
        gap = self.svg.viewport_to_unit(GAP) / scale
        font = self.svg.viewport_to_unit(FONT) / scale
        ux, uy = (ex - sx) / length, (ey - sy) / length
        nx, ny = -uy, ux
        zero = (zx - sx) * ux + (zy - sy) * uy
        horizontal = abs(ux) >= abs(uy)

        node.path = f"M {sx:.4f},{sy:.4f} L {ex:.4f},{ey:.4f}"
        node.set("sodipodi:nodetypes", None)

        group = Group()
        node.getparent().insert(node.getparent().index(node), group)
        group.append(node)

        ticks = []
        labels = []
        # Positive values go right on a horizontal axis and up on a vertical
        # one, whichever end was drawn first.
        sign = (1 if ux > 0 else -1) if horizontal else (1 if uy < 0 else -1)
        eps = 1e-6 * length
        below = math.floor(-zero / spacing - 1e-9)
        above = math.ceil((length - zero) / spacing + 1e-9)
        for step in range(below, above + 1):
            along = zero + step * spacing
            if step == 0 or along < -eps or along > length + eps:
                continue
            value = step * sign
            px, py = sx + ux * along, sy + uy * along
            ticks.append(
                f"M {px + nx * tick:.4f},{py + ny * tick:.4f} "
                f"L {px - nx * tick:.4f},{py - ny * tick:.4f}"
            )
            if not LABELS:
                continue
            if horizontal:
                labels.append((px, py + tick + gap + font * 0.75, "middle", value))
            else:
                labels.append((px - tick - gap, py + font * 0.35, "end", value))

        if ticks:
            marks = PathElement()
            marks.path = " ".join(ticks)
            marks.style = {
                "fill": "none",
                "stroke": node.style.get("stroke", "#000000"),
                "stroke-width": node.style.get("stroke-width", "0.5"),
            }
            group.append(marks)
        for x, y, anchor, value in labels:
            text = TextElement(x=f"{x:.4f}", y=f"{y:.4f}")
            text.text = f"${value}$"
            text.style = {
                "font-size": f"{font:.4f}",
                "font-family": "monospace",
                "fill": "#000000",
                "stroke": "none",
                "text-anchor": anchor,
                "text-align": "center" if anchor == "middle" else "end",
            }
            group.append(text)


if __name__ == "__main__":
    Axis().run()
