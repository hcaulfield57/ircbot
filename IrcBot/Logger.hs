module IrcBot.Logger (logIrc) where

import Control.Concurrent
import Control.Monad (when)
import Data.List
import Network.Socket
import System.Directory
import Text.Parsec
import Text.Parsec.String (Parser)

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
                        then ""
                        else ch
                hIrc' = hIrc { chan = chan hIrc ++ [chans] }
            when (not $ null chans)
                (forkIO (logChan sockfd ch) >> return ())
            handleList hIrc'

logChan :: Socket -> String -> IO ()
logChan sockfd ch = do
    sendIrc sockfd $ "JOIN " ++ ch
    writeOutput
  where writeOutput = do
          output <- recvIrc sockfd
          writeFile ch output
          writeOutput


parseList :: Parser String
parseList =
    try channel <|>
    endList 

channel :: Parser String
channel = do
    many $ noneOf "#"
    ch <- channelName
    return ch
  where channelName = do
          char '#'
          many anyChar
          many $ noneOf " "

endList :: Parser String
endList = do
    string "End of LIST"
    error "End of List Output"
