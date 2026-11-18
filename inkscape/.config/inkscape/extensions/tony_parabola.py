#!/usr/bin/env python3
import inkex
from inkex import PathElement


class Parabola(inkex.EffectExtension):
    def effect(self):
        for node in self.svg.selection.filter(PathElement).values():
            self.parabola(node)

    def parabola(self, node):
        points = [tuple(p) for p in node.path.end_points]
        if len(points) < 2:
            return
        if len(points) == 2:
            (hx, hy), (px, py) = points
            if px == hx:
                return
            a = (py - hy) / (px - hx) ** 2
            b, c = -2 * a * hx, a * hx * hx + hy
            x0, x1 = hx - abs(px - hx), hx + abs(px - hx)
        else:
            (ax, ay), (bx, by), (cx, cy) = points[0], points[1], points[-1]
            if len({ax, bx, cx}) < 3:
                return
            # Lagrange form of the quadratic through the three points.
            la = ay / ((ax - bx) * (ax - cx))
            lb = by / ((bx - ax) * (bx - cx))
            lc = cy / ((cx - ax) * (cx - bx))
            a = la + lb + lc
            b = -(la * (bx + cx) + lb * (ax + cx) + lc * (ax + bx))
            c = la * bx * cx + lb * ax * cx + lc * ax * bx
            x0, x1 = min(ax, bx, cx), max(ax, bx, cx)

        def f(x):
            return a * x * x + b * x + c

        # A parabola segment is exactly a quadratic Bezier: the control point
        # is where the tangents at the two ends meet.
        xm = (x0 + x1) / 2
        ym = f(x0) + (2 * a * x0 + b) * (xm - x0)
        node.path = f"M {x0:.4f},{f(x0):.4f} Q {xm:.4f},{ym:.4f} {x1:.4f},{f(x1):.4f}"
        node.set("sodipodi:nodetypes", None)
        for key in ("marker-start", "marker-mid", "marker-end"):
            node.style[key] = "none"
        node.style["fill"] = "none"


if __name__ == "__main__":
    Parabola().run()
