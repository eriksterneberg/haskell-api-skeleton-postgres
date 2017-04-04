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
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}

module Models where

-- Imports Scotty
-- import qualified Web.Scotty as Scotty
-- import Network.HTTP.Types.Method (StdMethod(..))

-- Imports for Database
-- import Control.Monad.IO.Class  (liftIO)
-- import Database.Persist
-- import Database.Persist.Postgresql
import Database.Persist.TH
-- import Control.Monad.Logger (runStderrLoggingT)


-- DB
share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
User json
    email String
    name String Maybe
    age Int Maybe
    deriving Show
|]


-- doMigrations = runMigration migrateAll


-- inHandlerDb = liftIO . User.dbFunction

-- doDbStuff = do
--         johnId <- insert $ Person "John Doe" $ Just 35

--         john <- get johnId
--         liftIO $ print (john :: Maybe Person)


-- dbFunction query = runStderrLoggingT $ 
--         withPostgresqlPool connStr 10 $ 
--         \pool -> liftIO $ runSqlPersistMPool query pool          

-- initDb :: IO ()
-- initDb = runSqlite "dev.db" $ do
    -- liftIO $ putStrLn "Inializing database for User app"
--     doMigration
--     initTestData  


-- initTestData = do
--     johnId <- insert $ Person "John Doe" $ Just 35
--     john <- get johnId
--     liftIO $ print john    

--     -- oneJohnPost <- selectList [BlogPostAuthorId ==. johnId] [LimitTo 1]
--     -- liftIO $ print (oneJohnPost :: [Entity BlogPost])
--     liftIO $ print (john :: Maybe Person)


-- initTestData :: SqlBackend
-- initTestData = do
--     erikId <- insert (UserModel "erik.sterneberg@foo.com" Nothing (Just 34))
--     erik <- get erikId
--     liftIO $ print erik

    -- johnId <- insert $ User "John Doe" $ Just 35
--     john <- get johnId
--     liftIO $ print john    

--     -- oneJohnPost <- selectList [BlogPostAuthorId ==. johnId] [LimitTo 1]
--     -- liftIO $ print (oneJohnPost :: [Entity BlogPost])
--     liftIO $ print (john :: Maybe Person)



 -- = runSqlite "dev.db" $ do

--     erikId <- insert $ Person "Erik" $ Just 35
--     post <- selectList [] [LimitTo 1]
--     liftIO $ print (port :: [Person])

-- select' = runSqlite "dev.db" $ do
--     people <- selectList [PersonAge >. 25, PersonAge <=. 30] []
--     liftIO $ print people


-- initDb :: IO ()
-- initDb = withSqlitePool "test.db3" 10 $ runSqlPool doMigration'


--     erikId <- insert $ Person "Erik" $ Just 35
--     post <- selectList [] [LimitTo 1]
--     liftIO $ print (port :: [Person])

-- select' = runSqlite "dev.db" $ do
--     people <- selectList [PersonAge >. 25, PersonAge <=. 30] []
--     liftIO $ print people


-- END DB 


-- routes :: [Route]
-- routes =
--     [ 
--       Route GET "/user" $ Scotty.json allUsers  -- all users

--       -- Route to get user using a certain id
--     , Route GET "/user/:id" (do
--         id' <- Scotty.param "id"
--         Scotty.json (filter (matchesId id') allUsers)) -- one user

--       -- Route to create new user
--     , Route POST "/user" (do
--         user <- Scotty.jsonData :: Scotty.ActionM User
--         Scotty.json user)

--     ]
