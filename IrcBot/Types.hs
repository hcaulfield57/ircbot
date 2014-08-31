module IrcBot.Types
    ( IrcHandle(..)
    , Flag(..)
    ) where

import Control.Concurrent.MVar
import Network.Socket
import Text.Parsec

data IrcHandle = IrcHandle
    { args :: [Flag]        -- Additional commands
    , serv :: String        -- Server name
    , port :: String        -- Connection port
    , nick :: String        -- Bot nickname
    , pass :: String        -- Server password
    , sock :: Socket        -- Server connection socket
    , chan :: [String] }    -- Active server channels

data Flag
    = Serv String
    | Port String
    | Nick String
    | Pass String
    | Log
    deriving Eq
