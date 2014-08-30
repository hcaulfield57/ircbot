module IrcBot.IrcBot (mainLoop) where

import Control.Concurrent.MVar
import Control.Monad
import Control.Monad.Trans
import Data.List
import Text.Parsec

import IrcBot.Connection
import IrcBot.Types

mainLoop :: Socket -> IO ()
mainLoop hIrc = do
    mIrc <- newMVar hIrc
    let options = args hIrc
    when (any (== Log) options)
        (logIrc mIrc)
