{-# LANGUAGE DefaultSignatures #-}

module Language.Hasmtlib.Iteable where

import Language.Hasmtlib.Internal.Expr
import Data.Sequence (Seq)
import Data.Tree
  
-- | If condition (p :: b) then (t :: a) else (f :: a)
class Iteable b a where
  ite :: b -> a -> a -> a
  default ite :: (Iteable b c, Applicative f, f c ~ a) => b -> a -> a -> a
  ite p t f = liftA2 (ite p) t f

instance Iteable (Expr BoolType) (Expr t) where
  ite = Ite

instance Iteable Bool a where
  ite p t f = if p then t else f

instance Iteable (Expr BoolType) a => Iteable (Expr BoolType) [a]
instance Iteable (Expr BoolType) a => Iteable (Expr BoolType) (Maybe a)
instance Iteable (Expr BoolType) a => Iteable (Expr BoolType) (Seq a)
instance Iteable (Expr BoolType) a => Iteable (Expr BoolType) (Tree a)

instance (Iteable (expr BoolType) a, Iteable (expr BoolType) b) => Iteable (expr BoolType) (a,b) where
  ite p (a,b) (a',b') = (ite p a a', ite p b b')

instance (Iteable (expr BoolType) a, Iteable (expr BoolType) b, Iteable (expr BoolType) c) => Iteable (expr BoolType) (a,b,c) where
  ite p (a,b,c) (a',b',c') = (ite p a a', ite p b b', ite p c c')
  
instance (Iteable (expr BoolType) a, Iteable (expr BoolType) b, Iteable (expr BoolType) c, Iteable (expr BoolType) d) => Iteable (expr BoolType) (a,b,c,d) where
  ite p (a,b,c,d) (a',b',c',d') = (ite p a a', ite p b b', ite p c c', ite p d d')
  
instance (Iteable (expr BoolType) a, Iteable (expr BoolType) b, Iteable (expr BoolType) c, Iteable (expr BoolType) d, Iteable (expr BoolType) e) => Iteable (expr BoolType) (a,b,c,d,e) where
  ite p (a,b,c,d,e) (a',b',c',d',e') = (ite p a a', ite p b b', ite p c c', ite p d d', ite p e e')
  
instance (Iteable (expr BoolType) a, Iteable (expr BoolType) b, Iteable (expr BoolType) c, Iteable (expr BoolType) d, Iteable (expr BoolType) e, Iteable (expr BoolType) f) => Iteable (expr BoolType) (a,b,c,d,e,f) where
  ite p (a,b,c,d,e,f) (a',b',c',d',e',f') = (ite p a a', ite p b b', ite p c c', ite p d d', ite p e e', ite p f f')
  
instance (Iteable (expr BoolType) a, Iteable (expr BoolType) b, Iteable (expr BoolType) c, Iteable (expr BoolType) d, Iteable (expr BoolType) e, Iteable (expr BoolType) f, Iteable (expr BoolType) g) => Iteable (expr BoolType) (a,b,c,d,e,f,g) where
  ite p (a,b,c,d,e,f,g) (a',b',c',d',e',f',g') = (ite p a a', ite p b b', ite p c c', ite p d d', ite p e e', ite p f f', ite p g g')  
  
instance (Iteable (expr BoolType) a, Iteable (expr BoolType) b, Iteable (expr BoolType) c, Iteable (expr BoolType) d, Iteable (expr BoolType) e, Iteable (expr BoolType) f, Iteable (expr BoolType) g, Iteable (expr BoolType) h) => Iteable (expr BoolType) (a,b,c,d,e,f,g,h) where
  ite p (a,b,c,d,e,f,g,h) (a',b',c',d',e',f',g',h') = (ite p a a', ite p b b', ite p c c', ite p d d', ite p e e', ite p f f', ite p g g', ite p h h')