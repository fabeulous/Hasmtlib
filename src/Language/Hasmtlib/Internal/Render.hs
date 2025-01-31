module Language.Hasmtlib.Internal.Render where

import Data.ByteString.Builder
import Data.Foldable (foldl')
import Data.Sequence
import qualified Data.Text as Text
import qualified Data.Text.Encoding as Text.Enc
import GHC.TypeNats

-- | Render values to their SMTLib2-Lisp form, represented as 'Builder'.
class Render a where
  render :: a -> Builder

instance Render Bool where
  render b = if b then "true" else "false"
  {-# INLINEABLE render #-}

instance Render Nat where
  render = integerDec . fromIntegral
  {-# INLINEABLE render #-}

instance Render Integer where
  render x
    | x < 0     = "(- " <> integerDec (abs x) <> ")"
    | otherwise = integerDec x
  {-# INLINEABLE render #-}

instance Render Double where
  render x
    | x < 0     = "(- " <> formatDouble standardDefaultPrecision (abs x) <> ")"
    | otherwise = formatDouble standardDefaultPrecision x
  {-# INLINEABLE render #-}

instance Render Char where
  render = char8
  {-# INLINE render #-}

instance Render String where
  render = string8
  {-# INLINE render #-}

instance Render Builder where
  render = id
  {-# INLINE render #-}

instance Render Text.Text where
  render = Text.Enc.encodeUtf8Builder
  {-# INLINE render #-}

renderUnary :: Render a => Builder -> a -> Builder
renderUnary op x = "(" <> op <> " " <> render x <> ")"
{-# INLINEABLE renderUnary #-}

renderBinary :: (Render a, Render b) => Builder -> a -> b -> Builder
renderBinary op x y = "(" <> op <> " " <> render x <> " " <> render y <> ")"
{-# INLINEABLE renderBinary #-}

renderTernary :: (Render a, Render b, Render c) => Builder -> a -> b -> c -> Builder
renderTernary op x y z = "(" <> op <> " " <> render x <> " " <> render y <> " " <> render z <> ")"
{-# INLINEABLE renderTernary #-}

renderNary :: Render a => Builder -> [a] -> Builder
renderNary op xs = "(" <> op <> renderedXs <> ")"
  where
    renderedXs = foldl' (\s x -> s <> " " <> render x) mempty xs
{-# INLINEABLE renderNary #-}

-- | Render values to their sequential SMTLib2-Lisp form, represented as a 'Seq' 'Builder'.
class RenderSeq a where
  renderSeq :: a -> Seq Builder
