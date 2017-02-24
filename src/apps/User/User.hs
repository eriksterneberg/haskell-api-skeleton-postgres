{-# LANGUAGE DeriveGeneric #-}

module User where

import GHC.Generics
import Web.Scotty
import Network.HTTP.Types.Method (StdMethod(..))
import Network.HTTP.Types.Status
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
jenny = User 1 "Jenny Doe" "password" "email@mail.com"


bob :: User
bob = User 2 "Bob Doe" "password" "email@mail.com"


allUsers :: [User]
allUsers = [bob, jenny]


matchesId :: Int -> User -> Bool
matchesId id' user = userId user == id'


routes :: [Route]
routes =
    [ 

      -- POST
      -- Route to create new user
      -- Should return 409 if resource does not exist
      -- Returns 201 if resource is created together with link to new resource
      -- TODO: Cannot work without integer id
      -- TODO: Crashes if cannot parse incoming JSON
      Route POST "/user" $ do
        user <- jsonData :: ActionM User
        status status201
        setHeader "Location" "/user/:newid"  -- TODO: Replace with real id
        json user

      -- GET
    , Route GET "/user" $ json allUsers  -- all users
      -- Route to get user using a certain id
      -- Should return 404 if no user found
    , Route GET "/user/:id" $ do
        id' <- param "id"
        json (filter (matchesId id') allUsers) -- one user

      -- PUT
      -- Route to update user
      -- Return 204 if no content was PUT
      -- Return 404 if user not found or id is otherwise invalid
    -- , Route PUT "/user/:id" (do
        -- json
      -- )

      -- DELETE
      -- Route to delete user
      -- Return 404 if user not found or is otherwise invalid
    -- , Route DELETE "/user:id" (
      -- id' <- param "id"
      -- delete
      -- )
    ]
