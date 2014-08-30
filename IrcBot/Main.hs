module Main (main) where

import System.Console.GetOpt
import System.Environment

import IrcBot.Connection
import IrcBot.IrcBot
import IrcBot.Types

flags :: [OptDescr Flag]
flags =
    [ Option "s" [] (ReqArg Serv "SERV") []
    , Option "p" [] (ReqArg Port "PORT") []
    , Option "n" [] (ReqArg Nick "NICK") []
    , Option "k" [] (ReqArg Pass "PASS") []
    , Option "l" [] (NoArg Log)          [] ]

main :: IO ()
main = do
    argv <- getArgs
    let hIrc = parseArgs argv
    sockfd <- connectIrc hIrc
    mainLoop sockfd

parseArgs :: [String] -> IrcHandle
parseArgs argv =
    let (opts, _, _) = getOpt RequireOrder flags argv
        server       = getServ opts
        portnumber   = getPort opts
        nickname     = getNick opts
        password     = getPass opts
        remArgs      = getArgs opts []
    in IrcHandle
        -- we get the other values later
        { args = remArgs
        , serv = server
        , port = portnumber
        , nick = nickname
        , pass = password } 
  where getServ []          = "irc.midgar.net"  -- default
        getServ (Serv x:xs) = x
        getServ (_:xs)      = getServ xs

        getPort []          = "6667"
        getPort (Port x:xs) = x
        getPort (_:xs)      = getPort xs

        getNick []          = "wedge"           -- default
        getNick (Nick x:xs) = x
        getNick (_:xs)      = getNick xs

        getPass []          = ""                -- no server password
        getPass (Pass x:xs) = x
        getPass (_:xs)      = getPass xs

        getArgs []          a = a
        getArgs (Serv _:xs) a = getArgs xs a
        getArgs (Port _:xs) a = getArgs xs a
        getArgs (Nick _:xs) a = getArgs xs a
        getArgs (Pass _:xs) a = getArgs xs a
        getArgs (x:xs)      a = getArgs xs (x:a)
