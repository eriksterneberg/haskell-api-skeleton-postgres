{-# LANGUAGE DeriveGeneric #-}

module Main where

import Web.Scotty
import Network.Wai.Middleware.HttpAuth
import Data.ByteString (ByteString)

import qualified Config
import qualified Router


authenticate :: ByteString -> ByteString -> IO Bool
authenticate user password = return (user == "zackarias.bergman@gmail.com" && password == "northernlights")


main :: IO ()
main = do
    putStrLn "Starting server..."
    port <- Config.getPort
    environment <- Config.getEnvironment
    scotty port $ do
        middleware $ Config.getLogger environment
        middleware $ basicAuth authenticate "Default Realm"
        Router.routes
