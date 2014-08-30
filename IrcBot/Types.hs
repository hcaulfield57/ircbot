module IrcBot.Types
    ( IrcBot
    , IrcHandle(..)
    , Flag(..)
    ) where

import Control.Concurrent.MVar
import Network.Socket
import Text.Parsec

-- What's the point of MVar, since I'm probably not going to be concurrently
-- writing to anything anyways. I think that I actually need to put something else in there,
-- it may not even be necessary to carry any state with Parsec, and just have it simply do
-- the parsing and let some other function handle IO things, etc. 
--
-- This is what i should fix first
type IrcBot = ParsecT String (MVar IrcHandle)

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
