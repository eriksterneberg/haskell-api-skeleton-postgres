module Config ( getEnvironment
              , getLogger
              , getPort
              ) where

import Text.Read (readMaybe)
import Data.Maybe (fromMaybe, isNothing)
import Control.Monad (when)
import System.Environment (lookupEnv)
import Network.Wai (Middleware)
import Network.Wai.Middleware.RequestLogger


type Port = Int


data Environment = Development
                 | Production
                 | Test
                 deriving (Eq, Read, Show)


-- Get system variable or use default Environment
getEnvironment :: IO Environment
getEnvironment = getDefault "ENVIRONMENT" readMaybe Development


-- Get system environment variable or use default 3000
getPort :: IO Port
getPort = getDefault "PORT" readMaybe 3000


-- Get system environment variable or use default
getDefault :: Show b => String -> (String -> Maybe b) -> b -> IO b
getDefault env parser defaultVal = do
    systemVal <- lookupEnv env
    let port = systemVal >>= parser
    when (isNothing port) $ putStrLn ("Using default value=" ++ show defaultVal ++ ". Set environment PORT=X to override default.")
    return $ fromMaybe defaultVal $ port


-- Get request logger
getLogger :: Environment -> Middleware
getLogger Development = logStdoutDev
getLogger Production  = logStdout
getLogger _           = id
