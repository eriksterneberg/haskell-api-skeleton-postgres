{-# LANGUAGE DeriveGeneric #-}

module User where

import GHC.Generics
import Web.Scotty
import Network.HTTP.Types.Method (StdMethod(..))
import Data.Aeson (FromJSON, ToJSON)

import Types


data User = User { userId :: Int
                 , userName :: String
                 , password :: String
                 , email :: String
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
    [ 

    -- AUTHENTICATION
      -- Login:
      -- Route GET "/token" $ do
        -- constructing a JWT for the user using GET parameters username and password

      -- Authenticate request:
      -- Route GET "/authenticate" $ do
        -- return the user if the JWT checks out
        -- the website can of course cache the user's name and email if it wants to
        -- that cache can be invalidated when the user logs out
        -- otherwise the cache will never expire. Redis?
    -- END AUTHENTICATION

    -- USER OPERATIONS
      Route GET "/user" $ json allUsers  -- all users
    , Route GET "/user/:id" (do
        id' <- param "id"
        json (filter (matchesId id') allUsers)) -- one user
    , Route POST "/user" (do
        user <- jsonData :: ActionM User
        json user)
      -- Route to get user using a certain id
      -- Route to create new user
      -- Route to update user
      -- Route to delete user
    -- END USER OPERATIONS
    ]
