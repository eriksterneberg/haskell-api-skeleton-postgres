{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}

module Models where

import           Control.Monad.IO.Class     (MonadIO, liftIO)
import           Control.Monad.Trans.Reader (ReaderT)
import           Data.Pool ()
import           Database.Persist.Postgresql as DB

import qualified Web.Scotty()

import Data.Pool (Pool)
import Database.Persist.TH


share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
AuthUser json
    email String
    name String Maybe
    age Int Maybe
    deriving Show
|]


-- Todo: make db migration work in Scotty app. Currently the types don't line up
runDb' :: (BaseBackend backend ~ SqlBackend, MonadIO m,
                 IsPersistBackend backend) =>
                Pool backend -> ReaderT backend IO a -> m a
runDb' pool query = liftIO (DB.runSqlPool query pool)


doMigrations :: ReaderT DB.SqlBackend IO ()
doMigrations = DB.runMigration Models.migrateAll
