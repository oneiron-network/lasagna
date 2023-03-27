pub type FieldConfig {
  modulus: Int,
}

pub fn fp() {
  FieldConfig {
    modulus: 28948022309329048855892746252171976963363056481941560715954676764349967630337,
  }
}

pub fn fq() {
  FieldConfig {
    modulus: 28948022309329048855892746252171976963363056481941647379679742748393362948097,
  }
}

pub fn mul(m: Int, x: Int, y: Int) -> Int {
  x * y % m
}

pub fn square(m: Int, x: Int) -> Int {
  mul(m, x, x)
}

pub fn pow(m: Int, x: Int, y: Int) -> Int {
  if y < 0 {
    pow(m, inverse(m, x), -y)
  } else {
    pow_internal(m, x, y, 1)
  }
}

fn pow_internal(m: Int, x: Int, y: Int, r: Int) -> Int {
  when y is {
    0 ->
      r
    _ -> {
      let (x, y, r) =
        when y % 2 is {
          0 ->
            (square(m, x), y / 2, r)
          _ ->
            (x, y - 1, mul(m, x, r))
        }
      pow_internal(m, x, y, r)
    }
  }
}

pub fn div(m: Int, x: Int, y: Int) -> Int {
  mul(m, x, inverse(m, y))
}

pub fn add(m: Int, x: Int, y: Int) -> Int {
  ( x + y ) % m
}

pub fn sub(m: Int, x: Int, y: Int) -> Int {
  ( x - y ) % m
}

pub fn neg(m: Int, x: Int) -> Int {
  -x % m
}

/// Computes the multiplicative inverse of x in the field with the given modulus.
pub fn inverse(m: Int, x: Int) -> Int {
  if x < 0 {
    inverse(m, -x)
  } else {
    when x is {
      1 ->
        1
      _ ->
        inverse_internal(m, m, x, 0, 1)
    }
  }
}

pub fn inverse_internal(m: Int, r: Int, new_r: Int, t: Int, new_t: Int) -> Int {
  when new_r is {
    0 ->
      t % m
    _ -> {
      let q =
        r / new_r
      inverse_internal(m, new_r, r - q * new_r, new_t, t - q * new_t)
    }
  }
}

// Tests

fn check_inverse(m: Int, x: Int) -> Bool {
  let y =
    inverse(m, x)
  (x != 1 && x != m - 1 || x == y)? && (y > 0)? && (y < m)? && (mul(m, x, y) == 1)?
}

fn check_inverse_recursive(m: Int, x: Int) -> Bool {
  when x is {
    1 ->
      check_inverse(m, x)
    _ ->
      check_inverse(m, x) && check_inverse_recursive(m, x - 1)
  }
}

test inverse_all_in_1907() {
  let m =
    1907
  check_inverse_recursive(m, m - 1)
}

test inverse_1907_in_fp() {
  check_inverse_recursive(fp().modulus, 1907)
}

test inverse_1907_in_fq() {
  check_inverse_recursive(fq().modulus, 1907)
}

test sub_in_fp() {
  let m =
    fp().modulus
  let x =
    123456
  let y =
    456789
  let r =
    sub(m, x, y)
  (r >= 0)? && (r < m)? && (add(m, r, y) == x)?
}

test neq_in_fp() {
  let m =
    fp().modulus
  let x =
    1234567890987654321
  let r =
    neg(m, x)
  (r >= 0)? && (r < m)? && (add(m, r, x) == 0)?
}

test pow_in_fp() {
  let m =
    fp().modulus
  let x =
    1234567890987654321
  let y =
    121543
  let (r, r1) =
    (pow(m, x, y), pow(m, x, -y))
  (r > 0)? && (r < m)? && (r1 > 0)? && (r1 < m)? && (mul(m, r, r1) == 1)?
}

test invert_one_in_fp() {
  let m =
    fp().modulus
  (inverse(m, 1) == 1)?
}
