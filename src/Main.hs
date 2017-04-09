{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE TypeFamilies #-}

module Main where

import           Data.ByteString (ByteString)
-- import           Control.Applicative        (Applicative)
-- import           Control.Monad.IO.Class     (MonadIO, liftIO)
import           Control.Monad.Trans.Reader (runReaderT)  -- ReaderT
-- import           Control.Monad.Trans.Class  (MonadTrans, lift)
-- import           Control.Monad.Reader.Class (MonadReader)
-- import           Control.Monad.Reader       (asks)
import           Control.Monad.Logger       (runStdoutLoggingT)

import           Data.Pool ()
import           Database.Persist.Postgresql as DB
import qualified Web.Scotty()
import           Web.Scotty.Trans as S
import           Network.Wai.Middleware.HttpAuth (basicAuth)

import           Types
import qualified Config as Conf
import qualified Models
import qualified Actions


authenticate :: ByteString -> ByteString -> IO Bool
authenticate user password = return (user == "user@email.com" && password == "foobar")

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
    pool <- runStdoutLoggingT $ DB.createPostgresqlPool connStr 10
    Models.runDb' pool Models.doMigrations

    let cfg = Config pool environment
    let r m = runReaderT (runConfigM m) cfg

    putStrLn "Starting Scotty server..."
    port <- Conf.getPort
    scottyT port r (app cfg)


app :: Config -> ScottyT Error ConfigM ()
app cfg = do
    middleware $ Conf.getLogger (getEnvironment cfg)
    -- middleware $ basicAuth authenticate "Default Realm"
    S.get "/"            Actions.getExplorableEndpoints
    S.get "/user/:id"    Actions.getSingleUser
    S.get "/user"        Actions.getAllUsers
    S.post "/user"       Actions.saveNewUser
    -- S.put "/user" Actions.updateUser -- Update 1 user with put
    S.delete "/user/:id" Actions.deleteUser
    notFound $ text "there is no such route."      
