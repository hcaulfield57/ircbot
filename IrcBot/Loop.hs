module IrcBot.Loop (mainLoop) where

import Control.Concurrent.MVar
import Control.Monad
import Control.Monad.Trans
import Data.List
import Text.Parsec

import IrcBot.Connection
import IrcBot.Logger
import IrcBot.Types

mainLoop :: IrcHandle -> IO ()
mainLoop hIrc = do
    when (any (== Log) (args hIrc))
        (logIrc hIrc)
    -- other functions later
