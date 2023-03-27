use lasagna/curves/pasta.{
  CurveConfig, Projective, normalize_projective, pallas, to_projective,
}
use lasagna/fields as f

/// Check if a point is the zero point (the point at infinity).
pub fn is_zero(p: Projective) -> Bool {
  p.z == 0
}

/// Return the zero point (the point at infinity).
pub fn zero() {
  Projective(0, 1, 0)
}

/// Return the generator point of the curve.
pub fn one(curve: CurveConfig) {
  to_projective(curve.generator)
}

/// Negate a curve point: `-P`.
pub fn neg(curve: CurveConfig, p: Projective) -> Projective {
  if is_zero(p) {
    p
  } else {
    Projective(p.x, f.neg(curve.base_field.modulus, p.y), p.z)
  }
}

/// Double a curve point: `P + P`.
pub fn double(curve: CurveConfig, p: Projective) -> Projective {
  let m =
    curve.base_field.modulus
  let (x, y, z) =
    (p.x, p.y, p.z)
  let (a, b) =
    (x * x, y * y)
  let c =
    b * b
  let d =
    2 * ( ( x + b ) * ( x + b ) - a - c )
  let e =
    3 * a
  let x3 =
    f.sub(m, e * e, 2 * d)
  let y3 =
    f.sub(m, e * ( d - x3 ), 8 * c)
  let z3 =
    f.mul(m, 2 * y, z)
  Projective(x3, y3, z3)
}

/// Add two curve points: `P1 + P2`.
pub fn add(curve: CurveConfig, p1: Projective, p2: Projective) -> Projective {
  if is_zero(p1) {
    p2
  } else if is_zero(p2) {
    p1
  } else if p1.x == p2.x {
    if p1.y == p2.y {
      double(curve, p1)
    } else {
      zero()
    }
  } else {
    let p2 =
      normalize_projective(curve, p2)
    let m =
      curve.base_field.modulus
    let (x1, y1, z1) =
      (p1.x, p1.y, p1.z)
    let (x2, y2) =
      (p2.x, p2.y)
    let z1z1 =
      z1 * z1
    let u2 =
      x2 * z1z1
    let s2 =
      y2 * z1 * z1z1
    let h =
      u2 - x1
    let i =
      2 * h * h
    let j =
      h * i
    let r =
      2 * ( s2 - y1 )
    let v =
      x1 * i
    let x3 =
      f.sub(m, r * r, j + 2 * v)
    let y3 =
      f.sub(m, r * ( v - x3 ), 2 * y1 * j)
    let z3 =
      f.mul(m, z1 * h, 2)
    Projective(x3, y3, z3)
  }
}

/// Scalar multiplication: `n * P`.
pub fn scalar_mul(curve: CurveConfig, p: Projective, n: Int) -> Projective {
  if n < 0 {
    scalar_mul(curve, neg(curve, p), -n)
  } else {
    scalar_mul_internal(curve, p, n % curve.scalar_field.modulus, zero())
  }
}

fn scalar_mul_internal(
  curve: CurveConfig,
  p: Projective,
  n: Int,
  r: Projective,
) -> Projective {
  when n is {
    0 ->
      r
    _ -> {
      let (p, n, r) =
        when n % 2 is {
          0 ->
            (double(curve, p), n / 2, r)
          _ ->
            (p, n - 1, add(curve, r, p))
        }
      scalar_mul_internal(curve, p, n, r)
    }
  }
}

// Tests

test scalar_mul_zero() {
  let curve =
    pallas()
  is_zero(scalar_mul(curve, zero(), 0))? && is_zero(
    scalar_mul(curve, one(curve), 0),
  )?
}

test scalar_mul_one() {
  let curve =
    pallas()
  let p =
    one(curve)
  scalar_mul(curve, p, 1) == p
}

test scalar_mul_two() {
  let curve =
    pallas()
  let p =
    one(curve)
  (normalize_projective(curve, scalar_mul(curve, p, 2)) == normalize_projective(
    curve,
    double(curve, p),
  ))?
}

test scalar_mul_three() {
  let curve =
    pallas()
  let p =
    one(curve)
  (normalize_projective(curve, scalar_mul(curve, p, 3)) == normalize_projective(
    curve,
    add(curve, p, double(curve, p)),
  ))?
}

test scalar_mul_four() {
  let curve =
    pallas()
  let p =
    one(curve)
  (normalize_projective(curve, scalar_mul(curve, p, 4)) == normalize_projective(
    curve,
    double(curve, double(curve, p)),
  ))?
}
