//// Types and helper functions for Pasta elliptic curves as described
//// in https://o1-labs.github.io/proof-systems/specs/pasta.html

use lasagna/curve.{Affine, CurveConfig}
use lasagna/field.{FieldConfig}

/// Field `Fp` with `modulus = 28948022309329048855892746252171976963363056481941560715954676764349967630337`.
pub fn fp() {
  FieldConfig {
    modulus: 28948022309329048855892746252171976963363056481941560715954676764349967630337,
  }
}

/// Field `Fq` with `modulus = 28948022309329048855892746252171976963363056481941647379679742748393362948097`.
pub fn fq() {
  FieldConfig {
    modulus: 28948022309329048855892746252171976963363056481941647379679742748393362948097,
  }
}

/// Configuration for the Pallas curve. Base field is `Fp`, scalar field is `Fq`.
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
