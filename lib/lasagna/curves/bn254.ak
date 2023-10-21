//// Types and helper functions for Pasta elliptic curves as described
//// in https://o1-labs.github.io/proof-systems/specs/pasta.html

use lasagna/curve.{Affine, CurveConfig}
use lasagna/field.{FieldConfig}

/// Field `Fq` with `modulus = 21888242871839275222246405745257275088696311157297823662689037894645226208583`.
pub fn fq() {
  FieldConfig {
    modulus: 21888242871839275222246405745257275088696311157297823662689037894645226208583,
  }
}

/// Field `Fr` with `modulus = 21888242871839275222246405745257275088548364400416034343698204186575808495617`.
pub fn fr() {
  FieldConfig {
    modulus: 21888242871839275222246405745257275088548364400416034343698204186575808495617,
  }
}

/// Configuration for the BN254 curve. Base field is `Fq`, scalar field is `Fr`.
/// The curve equation is `y^2 = x^3 + 3`.
/// The generator point is `(1, 2)`.
pub fn bn254() {
  CurveConfig {
    base_field: fq(),
    scalar_field: fr(),
    b: 3,
    generator: Affine { x: 1, y: 2, infinity: False },
  }
}

/// Configuration for the Grumpkin curve. Base field is `Fr`, scalar field is `Fq`.
/// The curve equation is `y^2 = x^3 - 17`.
/// The generator point is `(1, 17631683881184975370165255887551781615748388533673675138860)`.
pub fn grumpkin() {
  CurveConfig {
    base_field: fr(),
    scalar_field: fq(),
    b: -17,
    generator: Affine {
      x: 1,
      y: 17631683881184975370165255887551781615748388533673675138860,
      infinity: False,
    },
  }
}
