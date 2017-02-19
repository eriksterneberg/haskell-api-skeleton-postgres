module Config where

import Text.Read (readMaybe)
import Data.Maybe (fromMaybe, isNothing)
import Control.Monad (when)
import System.Environment (lookupEnv)
import Network.Wai (Middleware)
import Network.Wai.Middleware.RequestLogger


type Port = Int


defaultPort :: Port
defaultPort = 3000


data Environment = Development
                 | Production
                 | Test
                 deriving (Eq, Read, Show)


getEnvironment :: IO Environment
getEnvironment = do
    systemVal <- lookupEnv "ENVIRONMENT"
    let environment = systemVal >>= \x -> readMaybe x :: Maybe Environment
    when (isNothing environment) $ putStrLn "Set environment variable ENVIRONMENT=X to override default environment setting."
    return $ fromMaybe Development $ environment


getPort :: IO Port
getPort = do
    systemVal <- lookupEnv "PORT"
    let port = systemVal >>= \x -> readMaybe x :: Maybe Int
    when (isNothing port) $ putStrLn "Set environment PORT=X to override default port."
    return $ fromMaybe defaultPort $ port


getLogger :: Environment -> Middleware
getLogger Development = logStdoutDev
getLogger Production  = logStdout
getLogger _           = logStdout  -- Todo: switch to no log
