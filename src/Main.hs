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

-- import Data.Aeson (FromJSON, ToJSON)
-- import Data.Text (pack)
-- import Data.Text.Lazy (fromStrict)
import qualified Web.Scotty as Scotty
import Network.HTTP.Types.Status (status404)

import Control.Monad.IO.Class  (liftIO)
import qualified Database.Persist.Postgresql as DB
import Control.Monad.Logger (runStderrLoggingT)
import Control.Monad.Trans.Reader (ReaderT)

import Web.Scotty
import Network.Wai.Middleware.HttpAuth
import Data.ByteString (ByteString)

import qualified Config
import qualified Models


authenticate :: ByteString -> ByteString -> IO Bool
authenticate user password = return (user == "user@email.com" && password == "foobar")


main :: IO ()
main = startServer


runDb pool query = liftIO (DB.runSqlPool query pool)


startServer :: IO()
startServer = do
    putStrLn "Initializing db..."
    pool <- runStderrLoggingT $ DB.createPostgresqlPool connStr 10
    runDb pool doMigrations
    -- runDb pool addTestData

    -- Get settings
    port <- Config.getPort
    environment <- Config.getEnvironment  

    putStrLn "Starting Scotty server..."
    scotty port $ do

        -- Logger
        middleware $ Config.getLogger environment

        -- Authenticate request to service
        -- middleware $ basicAuth authenticate "Default Realm"

        -- TODO: fill in explorable routes
        get "/" $ text "Explorable endpoints: (list endpoints)"

        -- Get all users
        get "/user" $ do
            allUsers <- runDb pool (DB.selectList [] [])
            Scotty.json (allUsers :: [DB.Entity Models.User])

        -- Get 1 user
        get "/user/:id" $ do
            id' <- param "id"
            user <- runDb pool $ DB.get (DB.toSqlKey (read id'))
            case user of
                Nothing -> Scotty.status status404
                Just (user') -> Scotty.json (user' :: Models.User)

        -- Post 1 user
        -- Update 1 user with put
        -- Delete 1 user
        -- delete "/user/:id"

        notFound $ text "there is no such route."


addTestData :: ReaderT DB.SqlBackend IO ()                        
addTestData = do
    erikId <- DB.insert (Models.User "erik.sterneberg@foo.com" Nothing (Just 34))
    erik <- DB.get erikId
    liftIO $ print erik                        


connStr :: DB.ConnectionString
connStr = "host=localhost dbname=user user=postgres password=postgres port=5432"


doMigrations = DB.runMigration Models.migrateAll
