{-# LANGUAGE DeriveGeneric #-}

module Main where

import Web.Scotty
import Network.HTTP.Types.Method (StdMethod(..))
import Data.Text.Lazy (pack, intercalate)
import Data.Monoid ((<>))
import Network.Wai.Middleware.RequestLogger
import Network.Wai.Middleware.HttpAuth
import Network.Wai (Middleware)
import Data.ByteString (ByteString)
import System.Environment (lookupEnv)
import Text.Read (readMaybe)

import Types
import qualified User


routes :: ScottyM ()
routes = do

    -- All userdefined routes
    foldr1 (>>) $ map routeToScotty userdefinedRoutes

    -- Serve static files
    -- get "/404" $ file "404.html"

    -- Explorable routes
    addroute GET "/" $ text $ 
        intercalate "\n" $ "Explorable endpoints:" : (map (pack . show) userdefinedRoutes)

    -- Fallback on no matched route
    notFound $ text "there is no such route."


exampleRoutes :: [Route]
exampleRoutes =
    [ Route GET "/greeting/:name" (do
        name <- param "name"
        text ("Hello " <> name <> "!"))
    ]


-- Define your routes here.
userdefinedRoutes :: [Route]
userdefinedRoutes = concat [exampleRoutes, User.routes]


authenticate :: ByteString -> ByteString -> IO Bool
authenticate user password = return (user == "zackarias.bergman@gmail.com" && password == "northernlights")


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
    case systemVal of
        Nothing -> do
            putStrLn "No PORT suppplied on command line; using default."
            return defaultPort
        Just stringVal -> case readMaybe stringVal :: Maybe Int of 
            Nothing -> putStrLn (stringVal ++ " is not a valid integer to be used as port.") >> return defaultPort
            Just intVal -> return intVal


getLogger :: Environment -> Middleware
getLogger Development = logStdoutDev
getLogger Production  = logStdout
getLogger _           = logStdout  -- Todo: switch to no log


main :: IO ()
main = do
    putStrLn "Starting server..."
    port <- getPort
    environment <- getEnvironment
    scotty port $ do
        middleware $ getLogger environment
        middleware $ basicAuth authenticate "Default Realm"
        routes

