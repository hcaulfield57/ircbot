module IrcBot.Log (logIrc) where

import Control.Concurrent
import Control.Concurrent.MVar
import Network.Socket
import System.Directory
import Text.Parsec

import IrcBot.Connection
import IrcBot.Types

-- I'm moving MVars out of the code, so this will need to be rewritten.

logIrc :: MVar IrcHandle -> IO ()
logIrc mIrc = do
    hIrc <- takeMVar mIrc
    createDirectoryIfMissing False "/var/tmp/ircbot"
    setCurrentDirectory "/var/tmp/ircbot"
    sendIrc (sock hIrc) "LIST"
    putMVar mIrc hIrc
    handleList mIrc

-- Loops through server output, depending on what parsec functions will return, then
-- I know if we are done or not. If we find a channel that we are not currently logging, I
-- add it to the list and fork individual loggers that keep track of server output. 
handleList :: MVar IrcHandle -> IO ()
handleList mIrc = do
