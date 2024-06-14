![Static Badge](https://img.shields.io/badge/Lang-GHC2021-blue) [![Haskell-CI](https://github.com/bruderj15/Hasmtlib/actions/workflows/haskell-ci.yml/badge.svg)](https://github.com/bruderj15/Hasmtlib/actions/workflows/haskell-ci.yml) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# Hasmtlib

Hasmtlib is a library for generating SMTLib2-problems using a monad.
It takes care of encoding your problem, marshaling the data to an external solver and parsing and interpreting the result into Haskell types.
It is highly inspired by [ekmett/ersatz](https://github.com/ekmett/ersatz) which does the same for QSAT. Communication with external solvers is handled by [tweag/smtlib-backends](https://github.com/tweag/smtlib-backends).

Building expressions with type-level representations of the SMTLib2-Types guarantees type-safety for building expressions and when communicating with external solvers.

Although Hasmtlib does not yet make use of _observable_ sharing [(StableNames)](https://downloads.haskell.org/ghc/9.6.1/docs/libraries/base-4.18.0.0/System-Mem-StableName.html#:~:text=Stable%20Names,-data%20StableName%20a&text=An%20abstract%20name%20for%20an,makeStableName%20on%20the%20same%20object.) like Ersatz does, sharing in the API still allows for pure formula construction.

Therefore, this allows you to use the much richer subset of Haskell than a purely monadic meta-language would, which the strong [hgoes/smtlib2](https://github.com/hgoes/smtlib2) is one of. This ultimately results in extremely compact code.

For instance, to define the addition of two `V3` containing a Real-SMT-Expression:
```haskell
v3Add :: V3 (Expr RealType) -> V3 (Expr RealType) -> V3 (Expr RealType)
v3Add = liftA2 (+)
```
Even better, the [Expr-GADT](https://github.com/bruderj15/Hasmtlib/blob/master/src/Language/Hasmtlib/Internal/Expr.hs) allows for a polymorph definition:
```haskell
v3Add :: Num (Expr t) => V3 (Expr t) -> V3 (Expr t) -> V3 (Expr t)
v3Add = liftA2 (+)
```
This looks a lot like the [definition of Num](https://hackage.haskell.org/package/linear-1.23/docs/src/Linear.V3.html#local-6989586621679182277) for `V3 a`:
```haskell
instance Num a => Num (V3 a) where
  (+) :: V3 a -> V3 a -> V3 a
  (+) = liftA2 (+)
```
Hence, no extra definition is needed at all. We can use the existing instances:
```haskell
{-# LANGUAGE DataKinds #-}

import Language.Hasmtlib
import Linear

-- instances with default impl
instance Codec a => Codec (V3 a)
instance Variable a => Variable (V3 a)

main :: IO ()
main = do
  res <- solveWith cvc5 $ do
    setLogic "QF_NRA"

    u :: V3 (Expr RealType) <- variable
    v <- variable

    assert $ dot u v === 5

    return (u,v)

  print res
```
May print: `(Sat,Just (V3 (-2.0) (-1.0) 0.0,V3 (-2.0) (-1.0) 0.0))`

## Features

### Supported
- [x] SMTLib2 types in the haskell type
  ```haskell
    -- | Sorts in SMTLib - used as data-kind
    data SMTType = IntType | RealType | BoolType | BvType Nat
    data Expr (t :: SMTType) where ...
  
    ite :: Expr BoolType -> Expr t -> Expr t -> Expr t
  ```
- [x] Full SMTLib 2.6 standard support for Int, Real, Bool and unsigned BitVec
- [x] Type-level length-indexed Bitvectors for BitVec
  ```haskell
    bvConcat :: (KnownNat n, KnownNat m) => Expr (BvType n) -> Expr (BvType m) -> Expr (BvType (n + m))
  ```
- [x] Pure API with Expression-instances for Num, Floating, Bounded, ...
  ```haskell
    solveWith yices $ do
      setLogic "QF_BV"
      x <- var @(BvType 16)
      y <- var
      assert $ x - (maxBound `mod` 8) === y * y 
      return (x,y)
  ```
- [x] Add your own solvers via the [Solver type](https://github.com/bruderj15/Hasmtlib/blob/master/src/Language/Hasmtlib/Type/Solution.hs)
  ```haskell
    -- | Function that turns a state (SMT) into a result and a solution
    type Solver s m = s -> m (Result, Solution)
  ```
- [x] Solvers via external processes: CVC5, Z3, Yices2-SMT & MathSAT
  ```haskell
    (result, solution) <- solveWith mathsat $ do
      setLogic "QF_LIA" 
      assert $ ...
  ```
- [x] Incremental solving
  ```haskell
      cvc5Living <- cvc5Alive
      interactive cvc5Living $ do
        x <- var @IntType
        assert $ x === 42
        result <- checkSat
        push
        assert $ x <? 0
        (result, solution) <- solve
        case result of
          Sat   -> return solution
          Unsat -> pop >> ...
  ```
- [x] Pure quantifiers `for_all` and `exists`
  ```haskell
    solveWith z3 $ do
      setLogic "LIA"
      z <- var @IntType
      assert $ z === 0
      assert $
        for_all $ \x ->
            exists $ \y ->
              x + y === z
      return z
  ```

### Coming
- [ ] Observable sharing & access to the expression-tree (useful for rewriting, ...)
- [ ] (Maybe) signed BitVec with corresponding encoding on the type-level (unsigned, ones-complement, twos-complement)
- [ ] ...

## Examples
There are some examples in [here](https://github.com/bruderj15/Hasmtlib/tree/master/src/Language/Hasmtlib/Example).

## Contact information
Contributions, critics and bug reports are welcome!

Please feel free to contact me through GitHub.
