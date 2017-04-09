{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Types where

import           Control.Applicative        (Applicative)
import           Control.Monad.IO.Class     (MonadIO)
import           Control.Monad.Trans.Reader (ReaderT)
import           Control.Monad.Reader.Class (MonadReader)

import           Database.Persist.Postgresql as DB
import           Web.Scotty.Trans (ActionT)
import           Data.Text.Internal.Lazy as LazyText

import qualified Config as Conf


type Error = Text


data Config = Config { getPool :: DB.ConnectionPool
                     , getEnvironment :: Conf.Environment }


newtype ConfigM a = ConfigM
    { runConfigM :: ReaderT Config IO a
    } deriving (Applicative, Functor, Monad, MonadIO, MonadReader Config)


type ActionA = ActionT Error ConfigM