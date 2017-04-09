{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

-- {-# LANGUAGE DeriveGeneric #-}
-- {-# LANGUAGE EmptyDataDecls             #-}
-- {-# LANGUAGE FlexibleContexts           #-}
-- {-# LANGUAGE GADTs                      #-}
-- {-# LANGUAGE GeneralizedNewtypeDeriving #-}
-- {-# LANGUAGE MultiParamTypeClasses      #-}
-- {-# LANGUAGE OverloadedStrings          #-}
-- {-# LANGUAGE QuasiQuotes                #-}
-- {-# LANGUAGE TemplateHaskell            #-}
-- {-# LANGUAGE TypeFamilies               #-}
-- {-# LANGUAGE MultiParamTypeClasses #-}
-- {-# LANGUAGE FlexibleInstances #-}

module Models where

import Database.Persist.TH


share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
AuthUser json
    email String
    name String Maybe
    age Int Maybe
    deriving Show
|]
