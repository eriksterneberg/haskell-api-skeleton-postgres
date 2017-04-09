module Actions ( getSingleUser
               , saveNewUser
               , getAllUsers
               , getExplorableEndpoints) where

import           Data.Text.Lazy (intercalate)
import           Control.Monad.IO.Class     (MonadIO, liftIO)
import           Control.Monad.Trans.Class  (MonadTrans, lift)
import           Control.Monad.Reader       (asks)

import           Data.Aeson (decode)
import           Web.Scotty.Trans (body, json, status, text, param)
import           Database.Persist.Postgresql as DB
import           Network.HTTP.Types.Status

import qualified Models
import           Types



runDb :: (MonadTrans t, MonadIO (t ConfigM)) => DB.SqlPersistT IO a -> t ConfigM a
runDb query = do
    pool <- lift $ asks getPool
    liftIO (DB.runSqlPool query pool)


parseUser :: ActionA (Maybe Models.AuthUser)
parseUser = body >>= \b -> return $ (decode b :: Maybe Models.AuthUser)    


getSingleUser :: ActionA ()
getSingleUser = do
    id' <- param "id"
    user <- runDb $ DB.get (DB.toSqlKey (read id'))
    case user of
        Nothing -> status status404
        Just (user') -> json (user' :: Models.AuthUser) 


getAllUsers :: ActionA ()
getAllUsers = do
    allUsers <- runDb (DB.selectList [] [])        
    json (allUsers :: [DB.Entity Models.AuthUser])      


saveNewUser :: ActionA ()
saveNewUser = do
    user <- parseUser

    case user of
        Nothing ->
            status status400
        Just (user') -> do
            _ <- runDb $ DB.insert user'
            status created201


getExplorableEndpoints :: ActionA ()
getExplorableEndpoints = text $ message
    where message = intercalate "\n"
                    [ "Explorable endpoints:"
                    , "GET /user/:id  Get single user"
                    , "GET /user      Get a list of all users"
                    , "POST /user     Post a new user"
                    ]