{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TemplateHaskell #-}

{-|
Module      : Stack.Sig.Hackage
Description : Call Hackage APIs for User/Package Data
Copyright   : (c) FPComplete.com, 2015
License     : BSD3
Maintainer  : Tim Dysinger <tim@fpcomplete.com>
Stability   : experimental
Portability : POSIX
-}

module Stack.Sig.Hackage (packagesForMaintainer) where

import Control.Monad.Catch (MonadThrow, throwM)
import Control.Monad.IO.Class (MonadIO)
import Control.Monad.Trans.Control (MonadBaseControl)
import Data.Aeson (eitherDecode)
import Data.Aeson.TH (deriveFromJSON, defaultOptions)
import Data.List.Split (splitOn)
import Data.Maybe
import Data.Monoid ((<>))
import Network.HTTP.Conduit
       (parseUrl, withManager, httpLbs, requestHeaders, responseBody)
import Stack.Types

data UserDetail = UserDetail
    { groups :: [String]
    , _username :: String
    , _userid :: Integer
    } deriving (Show,Eq)

$(deriveFromJSON defaultOptions ''UserDetail)

-- | Given a hackage.org maintainer username, fetch all their
-- @PackageIdentifier@s.
packagesForMaintainer :: (MonadIO m, MonadThrow m, MonadBaseControl IO m)
                      => String -> m [PackageIdentifier]
packagesForMaintainer uname = do
    req <-
        parseUrl ("https://hackage.haskell.org/user/" <> uname)
    res <-
        withManager
            (httpLbs
                 (req
                  { requestHeaders = [("Accept", "application/json")]
                  }))
    case (fmap packageNamesForUser <$> eitherDecode)
             (responseBody res) of
        Left err -> throwM
                (HackageAPIException
                     ("Cloudn't retrieve packages for user " <> uname <> ": " <>
                      show err))
        Right pkgs -> return pkgs
    where packageNamesForUser :: UserDetail -> [PackageIdentifier]
          packageNamesForUser = mapMaybe packageNameFromGroup . groups
          packageNameFromGroup grp = case filter ("" /=) (splitOn "/" grp) of
                  [_,pkg,_] -> parsePackageIdentifierFromString pkg
                  _ -> Nothing
