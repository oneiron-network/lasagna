use lasagna/fields.{FieldConfig, fp, fq}
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

/// Curve configuration. Defines the curve equation and the base field. Scalar field is given for convenience.
/// The curve equation is `y^2 = x^3 + b`.
pub type CurveConfig {
  /// The base field of the curve. The curve equation is defined over this field, meaning that the `x` and `y` 
  /// coordinates, and the `b` coefficient are elements of this field.
  base_field: FieldConfig,
  /// The scalar field of the curve. This field represents the set of scalars that can be used to in the scalar
  /// multiplication of the curve points.
  scalar_field: FieldConfig,
  // a = 0 for pasta curves
  /// The constant `b` in the curve equation.
  b: Int,
  /// The generator point of the curve. All points on the curve can be obtained by scalar multiplication of this 
  /// point by elements of the scalar field.
  generator: Affine,
}

/// Transform a point from affine coordinates to projective coordinates.
pub fn to_projective(affine: Affine) -> Projective {
  when affine.infinity is {
    True ->
      Projective { x: 0, y: 1, z: 0 }
    False ->
      Projective { x: affine.x, y: affine.y, z: 1 }
  }
}

/// Normalize a point in projective coordinates. This means that the `z` coordinate is set to `1` for any point
/// other than the point at infinity.
pub fn normalize_projective(curve: CurveConfig, p: Projective) -> Projective {
  when p.z is {
    0 ->
      Projective { x: 0, y: 1, z: 0 }
    1 ->
      p
    _ ->
      to_projective(to_affine(curve, p))
  }
}

/// Transform a point from projective coordinates to affine coordinates.
pub fn to_affine(curve: CurveConfig, projective: Projective) -> Affine {
  when projective.z is {
    0 ->
      Affine { x: 0, y: 0, infinity: True }
    1 ->
      Affine { x: projective.x, y: projective.y, infinity: False }
    _ -> {
      let z_inv =
        f.inverse(curve.base_field.modulus, projective.z)
      let m =
        curve.base_field.modulus
      Affine {
        x: f.mul(m, projective.x, z_inv * z_inv),
        y: f.mul(m, projective.y, z_inv * z_inv * z_inv),
        infinity: False,
      }
    }
  }
}

/// Configuration for the Pallas curve.
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

/// Configuration for the Vesta curve.
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
