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

import Database.Persist.TH


share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
User json
    email String
    name String Maybe
    age Int Maybe
    deriving Show
|]


-- initTestData = do
--     johnId <- insert $ Person "John Doe" $ Just 35
--     john <- get johnId
--     liftIO $ print john    

--     -- oneJohnPost <- selectList [BlogPostAuthorId ==. johnId] [LimitTo 1]
--     -- liftIO $ print (oneJohnPost :: [Entity BlogPost])
--     liftIO $ print (john :: Maybe Person)


-- select' = runSqlite "dev.db" $ do
--     people <- selectList [PersonAge >. 25, PersonAge <=. 30] []
--     liftIO $ print people


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
