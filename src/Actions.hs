module Actions ( getSingleUser
               , saveNewUser
               , getAllUsers
               -- , deleteUser
               , updateUser
               , getExplorableEndpoints) where

import           Data.Text.Lazy (intercalate)
import           Control.Monad.IO.Class     (MonadIO, liftIO)
import           Control.Monad.Trans.Class  (MonadTrans, lift)
import           Control.Monad.Reader       (asks)

import           Data.Aeson (decode)
import           Web.Scotty.Trans (body, json, status, text, param)
import           Database.Persist.Postgresql as DB
import           Network.HTTP.Types.Status
import           Web.Scotty.Trans (ActionT)

import qualified Models
import           Types


getUser :: (MonadTrans t, MonadIO (t ConfigM)) =>
                 String -> t ConfigM (Maybe Models.AuthUser)
getUser id' = do
    user <- runDb $ DB.get (DB.toSqlKey (read id') :: Models.AuthUserId)
    return user


runDb :: (MonadTrans t, MonadIO (t ConfigM)) => DB.SqlPersistT IO a -> t ConfigM a
runDb query = do
    pool <- lift $ asks getPool
    liftIO (DB.runSqlPool query pool)


parseUser :: ActionA (Maybe Models.AuthUser)
parseUser = body >>= \b -> return $ (decode b :: Maybe Models.AuthUser)    


return' :: Monad m => Status -> (t -> ActionT e m ()) -> Maybe t -> ActionT e m ()
return' status' action user = do
    case user of
        Nothing -> status status'
        Just (user') -> action user'


getSingleUser :: ActionA ()
getSingleUser = param "id" >>= getUser >>= return' status404 (\x -> json (x :: Models.AuthUser))


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


-- deleteUser :: ActionA ()
-- deleteUser = do
--     id' <- param "id"
--     user <- getUser id'
--     case user of
--         Nothing -> status status404
--         Just _ -> do 
--             _ <- runDb $ DB.delete (DB.toSqlKey (Models.AuthUserId user) :: Models.AuthUserId)
--             status status204            

    -- param "id" >>= getUser >>= return' status404 (runDb $ DB.delete (DB.toSqlKey (read id') :: Models.AuthUserId)) >> status status204

updateUser :: ActionA ()
updateUser = do
    id' <- param "id"
    existingUser <- getUser id'
    case existingUser of
        Nothing ->
            status status404
        Just _ -> do
            updatedUser <- parseUser
            case updatedUser of
                Nothing ->
                    status status400
                Just updatedUser' ->
                    do
                        _ <- runDb $ DB.repsert (DB.toSqlKey (read id')) updatedUser'
                        status status204



getExplorableEndpoints :: ActionA ()
getExplorableEndpoints = text $ message
    where message = intercalate "\n"
                    [ "Explorable endpoints:"
                    , "GET /user/:id    Get single user"
                    , "GET /user        Get a list of all users"
                    , "POST /user       Post a new user"
                    , "DELETE /user/:id Delete a user"
                    , "PUT /user/:id    Update an existinguser"
                    ]
