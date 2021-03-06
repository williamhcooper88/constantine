# Constantine
# Copyright (c) 2018-2019    Status Research & Development GmbH
# Copyright (c) 2020-Present Mamy André-Ratsimbazafy
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  # Standard library
  std/macros,
  # Internal
  ./type_bigint, ./common,
  ./curves_declaration, ./curves_parser

export CurveFamily, Curve, SexticTwist

# ############################################################
#
#                 Field properties
#
# ############################################################

{.experimental: "dynamicBindSym".}

macro Mod*(C: static Curve): untyped =
  ## Get the Modulus associated to a curve
  result = bindSym($C & "_Modulus")

template getCurveBitwidth*(C: Curve): int =
  ## Returns the number of bits taken by the curve modulus
  CurveBitWidth[C]

template matchingBigInt*(C: static Curve): untyped =
  # Workaround: https://github.com/nim-lang/Nim/issues/16774
  BigInt[CurveBitWidth[C]]

template family*(C: Curve): CurveFamily =
  CurveFamilies[C]

template matchingLimbs2x*(C: Curve): untyped =
  const N2 = wordsRequired(getCurveBitwidth(C)) * 2 # TODO upstream, not precomputing N2 breaks semcheck
  array[N2, SecretWord] # TODO upstream, using Limbs[N2] breaks semcheck

# ############################################################
#
#                   Curve properties
#
# ############################################################

macro getCurveOrder*(C: static Curve): untyped =
  ## Get the curve order `r`
  ## i.e. the number of points on the elliptic curve
  result = bindSym($C & "_Order")

macro getCurveOrderBitwidth*(C: static Curve): untyped =
  ## Get the curve order `r`
  ## i.e. the number of points on the elliptic curve
  result = nnkDotExpr.newTree(
    getAST(getCurveOrder(C)),
    ident"bits"
  )

template matchingOrderBigInt*(C: static Curve): untyped =
  # Workaround: https://github.com/nim-lang/Nim/issues/16774
  BigInt[CurveOrderBitWidth[C]]

macro getEquationForm*(C: static Curve): untyped =
  ## Returns the equation form
  ## (ShortWeierstrass, Montgomery, Twisted Edwards, Weierstrass, ...)
  result = bindSym($C & "_equation_form")

macro getCoefA*(C: static Curve): untyped =
  ## Returns the A coefficient of the curve
  ## The return type is polymorphic, it can be an int
  ## or a bigInt depending on the curve
  result = bindSym($C & "_coef_A")

macro getCoefB*(C: static Curve): untyped =
  ## Returns the B coefficient of the curve
  ## The return type is polymorphic, it can be an int
  ## or a bigInt depending on the curve
  result = bindSym($C & "_coef_B")

macro get_QNR_Fp*(C: static Curve): untyped =
  ## Returns the tower extension quadratic non-residue in 𝔽p
  ## i.e. a number that is not a square in 𝔽p
  result = bindSym($C & "_nonresidue_quad_fp")

macro get_CNR_Fp2*(C: static Curve): untyped =
  ## Returns the tower extension cubic non-residue 𝔽p²
  ## i.e. a number that is not a cube in 𝔽p²
  ##
  ## The return value is a tuple (a, b)
  ## that corresponds to the number a + b𝑗
  ## with 𝑗 choosen for 𝑗² - QNR_Fp == 0
  ## i.e. if -1 is chosen as a quadratic non-residue 𝑗 = √-1
  ##      if -2 is chosen as a quadratic non-residue 𝑗 = √-2
  result = bindSym($C & "_nonresidue_cube_fp2")

macro getEmbeddingDegree*(C: static Curve): untyped =
  ## Returns the prime embedding degree,
  ## i.e. the smallest k such that r|𝑝^𝑘−1
  ## equivalently 𝑝^𝑘 ≡ 1 (mod r)
  ## with r the curve order and p its field modulus
  result = bindSym($C & "_embedding_degree")

macro getSexticTwist*(C: static Curve): untyped =
  ## Returns if D-Twist or M-Twist
  result = bindSym($C & "_sexticTwist")

macro get_SNR_Fp2*(C: static Curve): untyped =
  ## Returns the sextic non-residue in 𝔽p²
  ## choosen to build the twisted curve E'(𝔽p²)
  ## i.e. a number µ so that x⁶ - µ is irreducible
  result = bindSym($C & "_sexticNonResidue_fp2")
