Module Test where


addTestData :: ReaderT DB.SqlBackend IO ()                        
addTestData = do
    erikId <- DB.insert (Models.User "erik.sterneberg@foo.com" Nothing (Just 34))
    erik <- DB.get erikId
    liftIO $ print erik                        

--     -- oneJohnPost <- selectList [BlogPostAuthorId ==. johnId] [LimitTo 1]
--     -- liftIO $ print (oneJohnPost :: [Entity BlogPost])
--     liftIO $ print (john :: Maybe Person)




-- select' = runSqlite "dev.db" $ do
--     people <- selectList [PersonAge >. 25, PersonAge <=. 30] []
--     liftIO $ print people