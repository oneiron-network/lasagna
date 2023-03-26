use lasagna/curves/pasta.{Projective}

pub fn is_zero(pt: Projective) {
  pt.z == 0
}
