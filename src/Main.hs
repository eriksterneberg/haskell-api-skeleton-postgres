{-# LANGUAGE DeriveGeneric #-}

module Main where

import Web.Scotty
import Network.HTTP.Types.Method (StdMethod(..))
import Data.Text.Lazy (pack, intercalate)
import Data.Monoid ((<>))
import Network.Wai.Middleware.RequestLogger
import Network.Wai.Middleware.HttpAuth
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


getPort :: IO Port
getPort = do
    systemVal <- lookupEnv "PORT"
    let port = case systemVal of Nothing -> defaultPort
                                 Just stringVal -> case readMaybe stringVal :: Maybe Int of Nothing -> defaultPort
                                                                                            Just intVal -> intVal
    return port


main :: IO ()
main = do
    putStrLn "Starting server..."
    port <- getPort
    scotty port $ do
        -- middleware logStdout
        middleware logStdoutDev
        middleware $ basicAuth authenticate "Default Realm"
        routes

