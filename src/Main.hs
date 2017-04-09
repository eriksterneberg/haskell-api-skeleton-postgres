{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}

module Main where

import           Control.Applicative        (Applicative)
import           Control.Monad.IO.Class     (MonadIO, liftIO)
import           Control.Monad.Trans.Reader (ReaderT, runReaderT)
import           Control.Monad.Trans.Class  (MonadTrans, lift)
import           Control.Monad.Reader.Class (MonadReader)
import           Control.Monad.Reader       (asks)
import           Control.Monad.Logger       (runStdoutLoggingT)
import           Data.Monoid ((<>))
import qualified Data.Text.Lazy as T

import           Data.Pool ()
import           Database.Persist.Postgresql as DB

import qualified Web.Scotty()
import           Web.Scotty.Trans as S
import           Network.Wai.Middleware.RequestLogger(logStdoutDev)

import Data.Aeson (decode)
-- import Web.Scotty.Trans
-- import Network.Wai.Middleware.RequestLogger(logStdoutDev)
import Data.Text.Internal.Lazy as LazyText
-- import Web.Scotty.Internal.Types (ActionT)
import Network.HTTP.Types.Status

-- import qualified Database.Persist.Postgresql as DB

-- import Web.Scotty hiding (body, get, html, middleware)
-- import Web.Scotty.Trans (scottyT, ScottyT)
-- import Network.Wai.Middleware.HttpAuth
import Data.ByteString (ByteString)

-- import Data.Pool (Pool)

import qualified Config as Conf
import qualified Models
import qualified Actions


--Move to Auth.hs
authenticate :: ByteString -> ByteString -> IO Bool
authenticate user password = return (user == "user@email.com" && password == "foobar")
--- Auth.hs


--Move to Db.hs
runDb :: (MonadTrans t, MonadIO (t ConfigM)) => DB.SqlPersistT IO a -> t ConfigM a
runDb query = do
    pool <- lift $ asks getPool
    liftIO (DB.runSqlPool query pool)


doMigrations :: ReaderT DB.SqlBackend IO ()
doMigrations = DB.runMigration Models.migrateAll

--- Db.hs


--Move to Models.hs
parseUser :: ActionT Error ConfigM (Maybe Models.AuthUser)
parseUser = body >>= \b -> return $ (decode b :: Maybe Models.AuthUser)
--Models.hs


--Move to Config.hs, get from environment
connStr :: DB.ConnectionString
connStr = "host=localhost dbname=user_db user=postgres password=postgres port=5432"
--Config.hs


data Config = Config { getPool :: DB.ConnectionPool
                     , getEnvironment :: Conf.Environment }

newtype ConfigM a = ConfigM
    { runConfigM :: ReaderT Config IO a
    } deriving (Applicative, Functor, Monad, MonadIO, MonadReader Config)


-- runApplication :: Config -> IO ()
-- runApplication c = do
--     o <- getOptions (environment c)
--     let r m = runReaderT (runConfigM m) c
--     scottyOptsT o r application


type Error = Text


main :: IO ()
main = do
    environment <- Conf.getEnvironment  

    -- Use different logger for production
    pool <- runStdoutLoggingT $ DB.createPostgresqlPool connStr 10
    let cfg = Config pool environment
    let r m = runReaderT (runConfigM m) cfg

    putStrLn "Starting Scotty server..."
    port <- Conf.getPort
    scottyT port r (app cfg)


app :: Config -> ScottyT Error ConfigM ()
app cfg = do
    -- runDb doMigrations

    -- Middleware
    middleware $ Conf.getLogger (getEnvironment cfg)

--     -- Authenticate request to service
--     -- middleware $ basicAuth authenticate "Default Realm"

    S.get "/" (html "Hello world")

    -- TODO: fill in explorable routes
    -- get "/" $ text "Explorable endpoints: (list endpoints)"

    -- Get all users
    S.get "/user" $ do
        -- allUsers <- runDb pool (DB.selectList [] [])
        allUsers <- runDb (DB.selectList [] [])        
        json (allUsers :: [DB.Entity Models.AuthUser])

    -- Get 1 user
    S.get "/user/:id" $ do
        id' <- param "id"
        user <- runDb $ DB.get (DB.toSqlKey (read id'))
        case user of
            Nothing ->
                status status404
            Just (user') ->
                json (user' :: Models.AuthUser)        

    -- Post 1 user
    S.post "/user" saveNewUser
        -- createdArticle article
        -- user <- parseUser

        -- case user of
        --     Nothing ->  -- Should be Left, and return error (define error in models)
        --         status status400
        --     Just (user') -> do
        --         _ <- runDb $ DB.insert user'
        --         status created201


    -- -- Post 1 user
    -- post "/user" $ do
    --     -- createdArticle article
    --     user <- parseUser :: ActionM (Maybe Models.AuthUser)

    --     case user of
    --         Nothing ->  -- Should be Left, and return error (define error in models)
    --             status status400
    --         Just (user') -> do
    --             _ <- runDb pool $ DB.insert user'
    --             status created201

    -- -- Update 1 user with put
    -- -- Delete 1 user
    -- -- delete "/user/:id"

    -- notFound $ text "there is no such route."      


saveNewUser :: ActionT Error ConfigM ()
saveNewUser = do
    user <- parseUser

    case user of
        Nothing ->
            status status400
        Just (user') -> do
            _ <- runDb $ DB.insert user'
            status created201

