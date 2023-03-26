use lasagna/fields.{FieldConfig, fp, fq}

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
