{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module User where

import GHC.Generics
import Web.Scotty
import Network.HTTP.Types.Method (StdMethod(..))
import Data.Aeson (FromJSON, ToJSON)

import Types


data User = User { userId :: Int
                 , userName :: String
                 } deriving (Show, Generic)


instance ToJSON User
instance FromJSON User


jenny :: User
jenny = User 1 "Jenny Doe"


bob :: User
bob = User 2 "Bob Doe"


allUsers :: [User]
allUsers = [bob, jenny]


matchesId :: Int -> User -> Bool
matchesId id' user = userId user == id'


routes :: [Route]
routes =
    [ Route GET "/user" $ json allUsers  -- all users
    , Route GET "/user/:id" (do
        id' <- param "id"
        json (filter (matchesId id') allUsers)) -- one user
    , Route POST "/user" (do
        user <- jsonData :: ActionM User
        json user)
    ]
