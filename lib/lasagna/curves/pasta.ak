use lasagna/fields.{FieldConfig, fp, fq}
use lasagna/fields as f

pub type Affine {
  x: Int,
  y: Int,
  infinity: Bool,
}

pub type Projective {
  x: Int,
  y: Int,
  z: Int,
}

pub type CurveConfig {
  base_field: FieldConfig,
  scalar_field: FieldConfig,
  // a = 0 for pasta curves
  b: Int,
  generator: Affine,
}

pub fn to_projective(affine: Affine) -> Projective {
  when affine.infinity is {
    True ->
      Projective { x: 0, y: 1, z: 0 }
    False ->
      Projective { x: affine.x, y: affine.y, z: 1 }
  }
}

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
