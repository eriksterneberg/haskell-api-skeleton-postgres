module Actions ( getSingleUser
               -- , saveNewUser
               -- , getAllUsers
               -- , deleteUser
               -- , updateUser
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


-- getUser :: (MonadTrans t, MonadIO (t ConfigM)) =>
                 -- String -> t ConfigM (Maybe Models.AuthUser)
getUser errorAction id' = do
    user <- runDb $ DB.get (DB.toSqlKey (read id') :: Models.AuthUserId)
    case user of Nothing      -> return (Left errorAction)
                 Just (user') -> return (Right user')


runDb :: (MonadTrans t, MonadIO (t ConfigM)) => DB.SqlPersistT IO a -> t ConfigM a
runDb query = lift $ asks getPool >>= \pool -> liftIO (DB.runSqlPool query pool)



-- parseUser :: ActionA (Maybe Models.AuthUser)
parseUser errorAction = do
    body' <- body
    case (decode body' :: Maybe Models.AuthUser) of
        Nothing     -> return (Left errorAction)
        Just (user) -> return (Right user)


toAction _ (Left errorAction) = errorAction
toAction action (Right user) = action user


getSingleUser :: ActionA ()
getSingleUser = param "id" >>= getUser (status status404) >>= toAction (\x -> json (x :: Models.AuthUser))


getAllUsers :: ActionA ()
getAllUsers = runDb (DB.selectList [] []) >>= \x -> json (x :: [DB.Entity Models.AuthUser])


saveNewUser :: ActionA ()
saveNewUser = parseUser (status status400) >>= toAction (\user -> do
    _ <- runDb $ DB.insert user
    status created201)


deleteUser :: ActionA ()
deleteUser = do
    id' <- param "id"
    param "id" >>= getUser (status status404) >>= toAction (\user -> do
        let userId = (DB.toSqlKey (read id') :: Models.AuthUserId)
        _ <- runDb $ DB.delete userId
        status status204
        )


-- updateUser :: ActionA ()
-- updateUser = do
--     id' <- param "id"
--     existingUser <- getUser id'
--     case existingUser of
--         Nothing ->
--             status status404
--         Just _ -> do
--             updatedUser <- parseUser
--             case updatedUser of
--                 Nothing ->
--                     status status400
--                 Just updatedUser' ->
--                     do
--                         _ <- runDb $ DB.repsert (DB.toSqlKey (read id')) updatedUser'
--                         status status204


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
