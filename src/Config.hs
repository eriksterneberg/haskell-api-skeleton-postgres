module Config ( getEnvironment
              , getLogger
              , getPort
              , getConnectionString
              , getAuthenticationMiddleware
              , Environment
              ) where

import           Data.ByteString (ByteString)
import           Text.Read (readMaybe)
import           Data.Maybe (fromMaybe, isNothing)
import           Control.Monad (when)
import           System.Environment (lookupEnv)

import           Network.Wai.Middleware.HttpAuth (basicAuth)
import           Database.Persist.Postgresql as DB
import           Network.Wai (Middleware)
import           Network.Wai.Middleware.RequestLogger ( logStdoutDev
                                                      , logStdout)


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
    let value = systemVal >>= parser
    when (isNothing value) $ putStrLn ("Set environment variable " ++
                                      env ++
                                      " to override default value of "
                                      ++ show defaultVal)
    return $ fromMaybe defaultVal value


getLogger :: Environment -> Middleware
getLogger Development = logStdoutDev
getLogger Production  = logStdout
getLogger _           = id


-- Todo: fix issue where CONN is not read
getConnectionString :: IO DB.ConnectionString
getConnectionString = getDefault "CONN" readMaybe connStr


connStr :: DB.ConnectionString
connStr = "host=localhost dbname=user_db user=postgres password=postgres port=5432"


authenticate :: ByteString -> ByteString -> IO Bool
authenticate user password = return (user == "user@email.com" && password == "foobar")


getAuthenticationMiddleware :: Environment -> Middleware
getAuthenticationMiddleware Production = basicAuth authenticate "Default Realm"
getAuthenticationMiddleware _          = id

