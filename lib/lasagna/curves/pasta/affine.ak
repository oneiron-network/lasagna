use lasagna/curves/pasta.{Affine, CurveConfig, pallas}
use lasagna/fields as f

pub fn is_zero(p: Affine) {
  p.infinity
}

pub fn zero() {
  Affine { x: 0, y: 0, infinity: True }
}

pub fn on_curve(curve: CurveConfig, point: Affine) -> Bool {
  let (x, y) =
    (point.x, point.y)
  if point.infinity {
    x == 0 && y == 0
  } else {
    let m =
      curve.base_field.modulus
    (f.pow(m, y, 2) == f.add(m, f.pow(m, x, 3), curve.b))?
  }
}

pub fn neg(curve: CurveConfig, p: Affine) {
  Affine { ..p, y: f.neg(curve.base_field.modulus, p.y) }
}

pub fn double(curve: CurveConfig, p: Affine) -> Affine {
  if is_zero(p) {
    p
  } else {
    let (x, y) =
      (p.x, p.y)
    let m =
      curve.base_field.modulus
    let t =
      f.div(m, 3 * x * x, f.mul(m, 2, y))
    let x3 =
      f.sub(m, t * t, 2 * x)
    let y3 =
      f.sub(m, 3 * x * t, f.add(m, t * t * t, y))
    Affine { x: x3, y: y3, infinity: False }
  }
}

pub fn add(curve: CurveConfig, p1: Affine, p2: Affine) -> Affine {
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
    let m =
      curve.base_field.modulus
    let (x1, y1, x2, y2) =
      (p1.x, p1.y, p2.x, p2.y)
    let t =
      f.div(m, f.sub(m, y2, y1), f.sub(m, x2, x1))
    let x3 =
      f.sub(m, t * t, x1 + x2)
    let y3 =
      f.sub(m, ( 2 * x1 + x2 ) * t, t * t * t + y1)
    Affine { x: x3, y: y3, infinity: False }
  }
}

// Tests

test double_zero() {
  let curve =
    pallas()
  let p =
    Affine { x: 0, y: 0, infinity: True }
  is_zero(double(curve, p))
}

test sanity_generator_on_the_curve() {
  let curve =
    pallas()
  on_curve(curve, curve.generator)?
}

fn check_on_the_curve(curve: CurveConfig, p: Affine) -> Bool {
  let p2 =
    double(curve, p)
  let p3 =
    add(curve, p, p2)
  (add(curve, p2, p) == p3)? && on_curve(curve, p)? && on_curve(curve, p2)? && on_curve(
    curve,
    p3,
  )? && (p == add(curve, p3, neg(curve, p2)))?
}

fn check_on_the_curve_recur(curve: CurveConfig, ps: List<Affine>) -> Bool {
  when ps is {
    [] ->
      True
    [p, ..ps] ->
      check_on_the_curve(curve, p) && check_on_the_curve_recur(curve, ps)
  }
}

test points_on_the_curve() {
  let curve =
    pallas()
  let p =
    Affine { x: f.neg(curve.base_field.modulus, 1), y: 2, infinity: False }
  check_on_the_curve_recur(curve, [p, curve.generator])
}
