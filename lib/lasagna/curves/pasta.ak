//// Types and helper functions for Pasta elliptic curves as described
//// in https://o1-labs.github.io/proof-systems/specs/pasta.html

use lasagna/curves/pasta/fields.{fp, fq}
use lasagna/fields as f

/// Affine coordinates `(x, y)` representation of a curve point.
/// The point at infinity is represented by `(x, y) = (0, 0)` and `infinity = True`.
pub type Affine {
  x: Int,
  y: Int,
  infinity: Bool,
}

/// Projective (Jacobian) coordinates `(X, Y, Z)` representation of a curve point.
/// Affine coordinates `(x, y)` are related to projective as `(x, y) = (X/Z^2, Y/Z^3)`.
/// The point at infinity is represented by `(X, Y, Z) = (0, 1, 0)`.
pub type Projective {
  x: Int,
  y: Int,
  z: Int,
}

/// Curve configuration. The curve equation is `y^2 = x^3 + b`.
///
/// `base_field` is the field over which the curve is defined: `x`, `y`, and `b` are elements of this field. 
///
/// `scalar_field` is the field over which the scalar multiplication of the curve points is defined:
/// its elements are the scalars that can be used to multiply the curve points.
///
/// `b` is the constant in the curve equation.
///
/// `generator` is the generator point of the curve. All points on the curve can be obtained by scalar multiplication
/// of this point by elements of the scalar field.
pub type CurveConfig {
  base_field: f.FieldConfig,
  scalar_field: f.FieldConfig,
  // a = 0 for pasta curves
  b: Int,
  generator: Affine,
}

/// Transform a point from affine coordinates to projective coordinates.
pub fn to_projective(affine: Affine) -> Projective {
  when affine.infinity is {
    True -> Projective { x: 0, y: 1, z: 0 }
    False -> Projective { x: affine.x, y: affine.y, z: 1 }
  }
}

/// Normalize a point in projective coordinates. This means that the `z` coordinate is set to `1` for any point
/// other than the point at infinity.
pub fn normalize_projective(curve: CurveConfig, p: Projective) -> Projective {
  when p.z is {
    0 -> Projective { x: 0, y: 1, z: 0 }
    1 -> p
    _ -> to_projective(to_affine(curve, p))
  }
}

/// Transform a point from projective coordinates to affine coordinates.
pub fn to_affine(curve: CurveConfig, projective: Projective) -> Affine {
  when projective.z is {
    0 -> Affine { x: 0, y: 0, infinity: True }
    1 -> Affine { x: projective.x, y: projective.y, infinity: False }
    _ -> {
      let z_inv = f.inverse(curve.base_field.modulus, projective.z)
      let m = curve.base_field.modulus
      Affine {
        x: f.mul(m, projective.x, z_inv * z_inv),
        y: f.mul(m, projective.y, z_inv * z_inv * z_inv),
        infinity: False,
      }
    }
  }
}

/// Configuration for the Pallas curve. Base field is `Fp`, scalar field is `Fq` (see `lasagna/fields.{fp, fq}`).
/// The curve equation is `y^2 = x^3 + 5`.
/// The generator point is `(1, 12418654782883325593414442427049395787963493412651469444558597405572177144507)`.
pub fn pallas() {
  CurveConfig {
    base_field: fp(),
    scalar_field: fq(),
    b: 5,
    generator: Affine {
      x: 1,
      y: 12418654782883325593414442427049395787963493412651469444558597405572177144507,
      infinity: False,
    },
  }
}

/// Configuration for the Vesta curve. Base field is `Fq`, scalar field is `Fp` (see `lasagna/fields.{fp, fq}`).
/// The curve equation is `y^2 = x^3 + 5`.
/// The generator point is `(1, 11426906929455361843568202299992114520848200991084027513389447476559454104162)`.
pub fn vesta() {
  CurveConfig {
    base_field: fq(),
    scalar_field: fp(),
    b: 5,
    generator: Affine {
      x: 1,
      y: 11426906929455361843568202299992114520848200991084027513389447476559454104162,
      infinity: False,
    },
  }
}
