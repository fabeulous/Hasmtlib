module Language.Hasmtlib.Internal.Render where

import Language.Hasmtlib.Internal.Expr
import Language.Hasmtlib.Type.SMT
import Data.ByteString.Builder
import Data.Sequence hiding ((|>), filter)
import Data.Coerce
import Control.Lens hiding (op)

class RenderSMTLib2 a where
  renderSMTLib2 :: a -> Builder

instance RenderSMTLib2 (Repr t) where
  renderSMTLib2 IntRepr  = "Int"
  renderSMTLib2 RealRepr = "Real"
  renderSMTLib2 BoolRepr = "Bool"
  {-# INLINEABLE renderSMTLib2 #-}
   
instance RenderSMTLib2 Bool where
  renderSMTLib2 b = if b then "true" else "false"
  {-# INLINEABLE renderSMTLib2 #-}

instance RenderSMTLib2 Integer where
  renderSMTLib2 x
    | x < 0     = "(- " <> integerDec (abs x) <> ")"
    | otherwise = integerDec x
  {-# INLINEABLE renderSMTLib2 #-}

instance RenderSMTLib2 Double where
  renderSMTLib2 x
    | x < 0     = "(- " <> formatDouble standardDefaultPrecision (abs x) <> ")"
    | otherwise = formatDouble standardDefaultPrecision x
  {-# INLINEABLE renderSMTLib2 #-}

instance RenderSMTLib2 Builder where
  renderSMTLib2 = id
  {-# INLINEABLE renderSMTLib2 #-}

instance RenderSMTLib2 (SMTVar t) where
  renderSMTLib2 v = "var_" <> intDec (coerce @(SMTVar t) @Int v)
  {-# INLINEABLE renderSMTLib2 #-}

renderUnary :: RenderSMTLib2 a => Builder -> a -> Builder
renderUnary op x = "(" <> op <> " " <> renderSMTLib2 x <> ")"
{-# INLINEABLE renderUnary #-}

renderBinary :: (RenderSMTLib2 a, RenderSMTLib2 b) => Builder -> a -> b -> Builder
renderBinary op x y = "(" <> op <> " " <> renderSMTLib2 x <> " " <> renderSMTLib2 y <> ")"
{-# INLINEABLE renderBinary #-}

renderTernary :: (RenderSMTLib2 a, RenderSMTLib2 b, RenderSMTLib2 c) => Builder -> a -> b -> c -> Builder
renderTernary op x y z = "(" <> op <> " " <> renderSMTLib2 x <> " " <> renderSMTLib2 y <> " " <> renderSMTLib2 z <> ")"
{-# INLINEABLE renderTernary #-}

instance KnownSMTRepr t => RenderSMTLib2 (Expr t) where
  renderSMTLib2 (Var v)                  = renderSMTLib2 v
  renderSMTLib2 (Constant (IntValue x))  = renderSMTLib2 x
  renderSMTLib2 (Constant (RealValue x)) = renderSMTLib2 x
  renderSMTLib2 (Constant (BoolValue x)) = renderSMTLib2 x

  renderSMTLib2 (Plus x y)   = renderBinary "+" x y
  renderSMTLib2 (Neg x)      = renderUnary  "-" x
  renderSMTLib2 (Mul x y)    = renderBinary "*" x y
  renderSMTLib2 (Abs x)      = renderUnary  "abs" x
  renderSMTLib2 (Mod x y)    = renderBinary "mod" x y
  renderSMTLib2 (Div x y)    = renderBinary "/" x y

  renderSMTLib2 (LTH x y)    = renderBinary "<" x y
  renderSMTLib2 (LTHE x y)   = renderBinary "<=" x y
  renderSMTLib2 (EQU x y)    = renderBinary "=" x y
  renderSMTLib2 (GTHE x y)   = renderBinary ">=" x y
  renderSMTLib2 (GTH x y)    = renderBinary ">" x y

  renderSMTLib2 (Not x)      = renderUnary  "not" x
  renderSMTLib2 (And x y)    = renderBinary "and" x y
  renderSMTLib2 (Or x y)     = renderBinary "or" x y
  renderSMTLib2 (Impl x y)   = renderBinary "=>" x y
  renderSMTLib2 (Xor x y)    = renderBinary "xor" x y

  -- TODO: Replace ??? with actual ones
  renderSMTLib2 Pi           = "real.pi"
  renderSMTLib2 (Sqrt x)     = renderUnary "sqrt" x
  renderSMTLib2 (Exp x)      = renderUnary "exp" x
--  renderSMTLib2 (Log x)      = renderUnary "???" x
  renderSMTLib2 (Sin x)      = renderUnary "sin" x
  renderSMTLib2 (Cos x)      = renderUnary "cos" x
  renderSMTLib2 (Tan x)      = renderUnary "tan" x
  renderSMTLib2 (Asin x)     = renderUnary "arcsin" x
  renderSMTLib2 (Acos x)     = renderUnary "arccos" x
  renderSMTLib2 (Atan x)     = renderUnary "arctan" x
--  renderSMTLib2 (Sinh x)     = renderUnary "???" x
--  renderSMTLib2 (Cosh x)     = renderUnary "???" x
--  renderSMTLib2 (Tanh x)     = renderUnary "???" x
--  renderSMTLib2 (Asinh x)    = renderUnary "???" x
--  renderSMTLib2 (Acosh x)    = renderUnary "???" x
--  renderSMTLib2 (Atanh x)    = renderUnary "???" x

  renderSMTLib2 (ToReal x)   = renderUnary "to_real" x
  renderSMTLib2 (ToInt x)    = renderUnary "to_int" x
  renderSMTLib2 (IsInt x)    = renderUnary "is_int" x

  renderSMTLib2 (Ite p t f)  = renderTernary "ite" p t f
  {-# INLINEABLE renderSMTLib2 #-}

instance RenderSMTLib2 SMTOption where
  renderSMTLib2 (PrintSuccess  b) = renderBinary "set-option" (":print-success" :: Builder)  b
  renderSMTLib2 (ProduceModels b) = renderBinary "set-option" (":produce-models" :: Builder) b

renderSetLogic :: Builder -> Builder
renderSetLogic = renderUnary "set-logic"

renderDeclareVar :: SMTVar t -> Repr t -> Builder
renderDeclareVar v = renderTernary "declare-fun" v ("()" :: Builder)
{-# INLINEABLE renderDeclareVar #-}

renderAssert :: Expr BoolType -> Builder
renderAssert = renderUnary "assert"
{-# INLINEABLE renderAssert #-}

renderCheckSat :: Builder
renderCheckSat = "(check-sat)"

renderGetModel :: Builder
renderGetModel = "(get-model)"

renderSMT :: SMT -> Seq Builder
renderSMT smt =
     fromList (renderSMTLib2 <$> smt^.options)
  >< maybe mempty (singleton . renderSetLogic . stringUtf8) (smt^.mlogic)
  >< renderVars (smt^.vars)
  >< fmap renderAssert (smt^.formulas)

renderVars :: Seq (SomeKnownSMTRepr SMTVar) -> Seq Builder
renderVars = fmap (\(SomeKnownSMTRepr v) -> renderDeclareVar v (goSing v))
  where
    goSing :: forall t. KnownSMTRepr t => SMTVar t -> Repr t
    goSing _ = singRepr @t