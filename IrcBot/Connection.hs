module IrcBot.Connection (connectIrc, sendIrc) where

import Control.Monad (when)
import qualified Data.ByteString.Char8 as B
import Network.Socket hiding (send)
import Network.Socket.ByteString
import Text.Printf

import IrcBot.Types

connectIrc :: IrcHandle -> IO Socket
connectIrc hIrc = do
    let server     = serv hIrc
        portnumber = port hIrc
        nickname   = nick hIrc
        password   = pass hIrc
    addrinfo <- return . head =<< getAddrInfo Nothing (Just server) (Just portnumber)
    sockfd   <- socket (addrFamily addrinfo) (addrSocketType addrinfo)
        (addrProtocol addrinfo)
    connect sockfd (addrAddress addrinfo)
    sendIrc sockfd $ "NICK " ++ nickname
    sendIrc sockfd $ "USER " ++ nickname ++ " 0 * :Just your friendly neighborhood bot."
    when (not $ null password)
        (sendIrc sockfd $ "PASS " ++ password)
    return sockfd

sendIrc :: Socket -> String -> IO ()
sendIrc sockfd str = do
    send sockfd . B.pack $ str ++ "\r\n"
    return ()
