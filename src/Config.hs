module Config where

import Text.Read (readMaybe)
import Data.Maybe (fromMaybe)
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
getEnvironment = fmap (maybe Development read) (lookupEnv "ENVIRONMENT")                 


getPort :: IO Port
getPort = do
    systemVal <- lookupEnv "PORT"
    return $ fromMaybe defaultPort $ systemVal >>= \x -> readMaybe x :: Maybe Int


getLogger :: Environment -> Middleware
getLogger Development = logStdoutDev
getLogger Production  = logStdout
getLogger _           = logStdout  -- Todo: switch to no log
