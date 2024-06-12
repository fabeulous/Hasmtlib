module Language.Hasmtlib.Solver.MathSAT where

import Language.Hasmtlib.Type.SMT
import Language.Hasmtlib.Type.Solution
import Language.Hasmtlib.Solver.Common
import Data.Default
import qualified SMTLIB.Backends.Process as P
import qualified SMTLIB.Backends as B
import Control.Monad.State

mathsatConf :: P.Config
mathsatConf = P.defaultConfig { P.exe = "mathsat", P.args = [] }

mathsat :: MonadIO m => Solver SMT m
mathsat = processSolver mathsatConf Nothing

mathsatDebug :: MonadIO m => Solver SMT m
mathsatDebug = processSolver mathsatConf $ Just def

mathsatAlive :: MonadIO m => m B.Solver
mathsatAlive = liftIO $ do
  handle  <- P.new mathsatConf
  B.initSolver B.Queuing $ P.toBackend handle