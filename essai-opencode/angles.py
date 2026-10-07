"""Calcul d'angles articulaires en 2D à partir de trois points."""

import math


def angle_articulaire(proximal, articulation, distal):
    """Angle (en degrés) au point `articulation` entre les segments vers `proximal` et `distal`."""
    ax, ay = proximal[0] - articulation[0], proximal[1] - articulation[1]
    bx, by = distal[0] - articulation[0], distal[1] - articulation[1]
    norme = math.hypot(ax, ay) * math.hypot(bx, by)
    if norme == 0:
        raise ValueError("Deux points sont confondus : angle indéfini.")
    cosinus = max(-1.0, min(1.0, (ax * bx + ay * by) / norme))
    return math.degrees(math.acos(cosinus))


def flexion_genou(hanche, genou, cheville):
    """Flexion du genou : 0° jambe tendue, valeur croissante quand le genou se plie."""
    return 180.0 - angle_articulaire(hanche, genou, cheville)


if __name__ == "__main__":
    hanche, genou, cheville = (0.0, 1.0), (0.05, 0.55), (0.0, 0.1)
    print(f"Flexion du genou : {flexion_genou(hanche, genou, cheville):.1f}°")
