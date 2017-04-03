{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE EmptyDataDecls             #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}

module Main where

import GHC.Generics
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (pack)
import Data.Text.Lazy (fromStrict)
import qualified Web.Scotty as Scotty

import Control.Monad.IO.Class  (liftIO)
import qualified Database.Persist.Postgresql as DB
import Control.Monad.Logger (runStderrLoggingT)
import Control.Monad.Trans.Reader (ReaderT)

import Web.Scotty
import Network.Wai.Middleware.HttpAuth
import Data.ByteString (ByteString)

import qualified Config
import qualified Router

import qualified User


authenticate :: ByteString -> ByteString -> IO Bool
authenticate user password = return (user == "user@email.com" && password == "foobar")


main :: IO ()
main = do
    startServer


runDb pool query = liftIO (DB.runSqlPool query pool)


-- instance ToJSON User.UserModel
-- instance FromJSON User.UserModel


startServer :: IO()
startServer = do
    putStrLn "Initializing db..."
    pool <- runStderrLoggingT $ DB.createPostgresqlPool connStr 10
    runDb pool doMigrations
    -- runDb pool addTestData

    putStrLn "Starting Scotty server..."

    -- Port for server to run on
    port <- Config.getPort

    -- Settings
    environment <- Config.getEnvironment

    scotty port $ do

        -- Logger
        middleware $ Config.getLogger environment

        -- Authenticate request to service
        -- middleware $ basicAuth authenticate "Default Realm"

        -- Routes
        -- Test, get all
        get "/" $ do
            allUsers <- runDb pool (DB.selectList [] [])
            -- liftIO $ print allUsers
            -- Scotty.json User.allUsers
            Scotty.json (allUsers :: [DB.Entity User.UserModel])

            -- Working
            -- Scotty.text $ fromStrict $ pack $ show (allUsers :: [DB.Entity User.UserModel])

        -- Other routes
        -- Router.routes


 -- transformers-0.5.2.0:Control.Monad.Trans.Reader.ReaderT
                        -- DB.SqlBackend IO ()

addTestData :: ReaderT DB.SqlBackend IO ()                        
addTestData = do
    erikId <- DB.insert (User.UserModel "erik.sterneberg@foo.com" Nothing (Just 34))
    erik <- DB.get erikId
    liftIO $ print erik                        



connStr :: DB.ConnectionString
connStr = "host=localhost dbname=user user=postgres password=postgres port=5432"


doMigrations = DB.runMigration User.migrateAll
