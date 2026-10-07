from angles import angle_articulaire, flexion_genou


def test_jambe_tendue():
    assert abs(flexion_genou((0, 2), (0, 1), (0, 0))) < 1e-9


def test_angle_droit():
    assert abs(angle_articulaire((1, 0), (0, 0), (0, 1)) - 90) < 1e-9


if __name__ == "__main__":
    test_jambe_tendue()
    test_angle_droit()
    print("Tous les tests passent.")
