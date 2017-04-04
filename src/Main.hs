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

import qualified Data.Aeson as Aeson    

import Data.Text (pack)
import Data.Text.Lazy (fromStrict)
import qualified Web.Scotty as Scotty
import Web.Scotty.Internal.Types (ActionT)
import Network.HTTP.Types.Status

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


runDb pool query = liftIO (DB.runSqlPool query pool)


connStr :: DB.ConnectionString
connStr = "host=localhost dbname=user user=postgres password=postgres port=5432"


doMigrations = DB.runMigration Models.migrateAll


main :: IO ()
main = startServer  


startServer :: IO()
startServer = do
    putStrLn "Initializing db..."
    pool <- runStderrLoggingT $ DB.createPostgresqlPool connStr 10
    runDb pool doMigrations

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
        post "/user" $ do
            -- article <- parseUserFromPOST
            -- insertArticle pool article
            -- createdArticle article
            user <- jsonData' :: Scotty.ActionM Models.User
            Scotty.json (user :: Models.User)            

            -- user <- Scotty.jsonData :: Scotty.ActionM User

        --     -- created201 if ok

        --     case user 
        --         Nothing ->  -- Should be Left, and return error (define error in models)
        --             Scotty.status status400

                -- Use status 409 Conflict if there was a conflict of some sort

        -- Update 1 user with put
        -- Delete 1 user
        -- delete "/user/:id"

        notFound $ text "there is no such route."      


-- jsonData' :: (A.FromJSON a) => ActionM a
jsonData' = do
    b <- body
    -- maybe (raise "jsonData: no parse") return $ Aeson.decode b        
    return $ Aeson.decode b


-- parseUserFromPOST :: ActionT Text IO (Maybe Models.User)
-- parseUserFromPOST = do b <- body
--     return $ (decode b :: Maybe Models.User)
--     where make
