Module Test where


addTestData :: ReaderT DB.SqlBackend IO ()                        
addTestData = do
    erikId <- DB.insert (Models.User "erik.sterneberg@foo.com" Nothing (Just 34))
    erik <- DB.get erikId
    liftIO $ print erik                        
