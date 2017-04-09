{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE TypeFamilies #-}

module Main where

-- import           Control.Applicative        (Applicative)
-- import           Control.Monad.IO.Class     (MonadIO, liftIO)
import           Control.Monad.Trans.Reader (runReaderT)  -- ReaderT
-- import           Control.Monad.Trans.Class  (MonadTrans, lift)
-- import           Control.Monad.Reader.Class (MonadReader)
-- import           Control.Monad.Reader       (asks)
import           Control.Monad.Logger       (runStdoutLoggingT)

import           Data.Pool ()
import           Database.Persist.Postgresql as DB (createPostgresqlPool)
import           Web.Scotty.Trans

import           Types
import qualified Config as Conf
import qualified Models
import           Actions

-- runApplication :: Config -> IO ()
-- runApplication c = do
--     o <- getOptions (environment c)
--     let r m = runReaderT (runConfigM m) c
--     scottyOptsT o r application


main :: IO ()
main = do
    environment <- Conf.getEnvironment
    connStr <- Conf.getConnectionString

    -- Use different logger for production
    pool <- runStdoutLoggingT $ createPostgresqlPool connStr 10
    Models.runDb' pool Models.doMigrations

    let cfg = Config pool environment
    let r m = runReaderT (runConfigM m) cfg

    putStrLn "Starting Scotty server..."
    port <- Conf.getPort
    scottyT port r (app cfg)


app :: Config -> ScottyT Error ConfigM ()
app cfg = do
    let environment = getEnvironment cfg
    middleware $ Conf.getLogger environment
    middleware $ Conf.getAuthenticationMiddleware environment
    get "/"            getExplorableEndpoints
    get "/user/:id"    getSingleUser
    -- Get user by username
    get "/user"        getAllUsers
    post "/user"       saveNewUser
    put "/user/:id"    updateUser    
    delete "/user/:id" deleteUser
    notFound $ text "there is no such route."      
