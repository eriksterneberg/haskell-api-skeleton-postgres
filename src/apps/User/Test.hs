{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}
module Main (main) where

import           Test.Hspec
import qualified Test.Hspec.Wai as Wai
-- ( get
--                              , post
--                              , matchStatus
--                              , with
--                              , shouldRespondWith)
import           Test.Hspec.Wai.JSON

import           Network.Wai (Application)
import qualified Web.Scotty as S
import           Data.Aeson (Value(..), object, (.=))

import Types
import qualified User


main :: IO ()
main = hspec spec


app :: IO Application
app = S.scottyApp $ do
    foldr1 (>>) $ map routeToScotty User.routes

  -- S.get "/some-json" $ do
    -- S.json $ object ["foo" .= Number 23, "bar" .= Number 42]


spec :: Spec
spec = Wai.with app $ do

    describe "GET /user" $ do
        it "responds with 200" $ do
            let expected = [json|[{"email":"email@mail.com","userName":"Jenny Doe","userId":1,"password":"password"}]|]
            Wai.get "/user" `Wai.shouldRespondWith` expected {Wai.matchStatus = 200}

    -- Add functional test to get user from database
    -- describe "GET /user:id"

    describe "POST /user" $ do
        it "responds with 201" $ do
            let postdata = [json|{userName: "Erik", password: "hockey", email: "foo@bar.com"}|]
            let expected = [json|{userName: "Erik", password: "hockey", email: "foo@bar.com", userId: 1}|]
            Wai.post "/user" postdata `Wai.shouldRespondWith` expected {Wai.matchStatus = 201}
