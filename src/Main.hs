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

    -- Port for server to run on
    port <- Config.getPort

    -- Settings
    environment <- Config.getEnvironment

    scotty port $ do

        -- Logger
        middleware $ Config.getLogger environment

        -- Authenticate request to service
        middleware $ basicAuth authenticate "Default Realm"

        -- Routes
        Router.routes
