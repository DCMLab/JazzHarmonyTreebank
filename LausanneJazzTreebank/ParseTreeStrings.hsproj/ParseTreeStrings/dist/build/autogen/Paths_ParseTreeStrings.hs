{-# LANGUAGE CPP #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -fno-warn-implicit-prelude #-}
module Paths_ParseTreeStrings (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [1,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/daniel/Library/Haskell/bin"
libdir     = "/Users/daniel/Library/Containers/com.haskellformac.Haskell.basic/Data/Library/Application Support/lib/ghc/ParseTreeStrings-1.0-6c93KpJ60sYA5xJodIvB4h"
dynlibdir  = "/Users/daniel/Library/Containers/com.haskellformac.Haskell.basic/Data/Library/Application Support/lib/ghc/ParseTreeStrings-1.0-6c93KpJ60sYA5xJodIvB4h"
datadir    = "/Users/daniel/Library/Containers/com.haskellformac.Haskell.basic/Data/Library/Application Support/share/ParseTreeStrings-1.0"
libexecdir = "/Users/daniel/Library/Containers/com.haskellformac.Haskell.basic/Data/Library/Application Support/libexec"
sysconfdir = "/Users/daniel/Library/Containers/com.haskellformac.Haskell.basic/Data/Library/Application Support/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "ParseTreeStrings_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "ParseTreeStrings_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "ParseTreeStrings_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "ParseTreeStrings_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "ParseTreeStrings_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "ParseTreeStrings_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
