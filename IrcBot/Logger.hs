module IrcBot.Log (logIrc) where

import Control.Concurrent
import Data.List
import Network.Socket
import System.Directory
import Text.Parsec

import IrcBot.Connection
import IrcBot.Types

logIrc :: IrcHandle -> IO ()
logIrc hIrc = do
    createDirectoryIfMissing False "/var/tmp/ircbot"
    setCurrentDirectory "/var/tmp/ircbot"
    sendIrc (sock hIrc) "LIST"
    handleList hIrc

handleList :: IrcHandle -> IO ()
handleList hIrc = do
    let sockfd = sock hIrc
    output <- recvIrc sockfd
    case parse parseList "SOCKET" output of
        Left err -> return ()
        Right ch -> do
            let chans = if any (== ch) (chan hIrc) 
                        then handleList hIrc
                        else ch
                hIrc' = hIrc { chan = chan hIrc ++ ch }
            forkIO (logChan sockfd ch)
            handleList hIrc

logChan :: Socket -> String -> IO ()
logChan sockfd ch = do
    sendIrc sockfd $ "JOIN " ++ ch
    writeOutput
  where writeOutput = do
          output <- recvIrc sockfd
          writeFile ch output
          writeOutput


parseList :: Parser String
parseList = do
    try channel <|>
    endList 

channel :: Parser String
channel = do
    many $ noneOf '#'
    ch <- channelName
    return ch
  where channelName = do
    char '#'
    many anyChar
    noneOf " "

endList :: Parser String
endList = do
    string "End of LIST"
    error "End of List Output"
