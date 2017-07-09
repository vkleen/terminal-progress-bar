{-# LANGUAGE PackageImports #-}

module Main where

import "async" Control.Concurrent.Async ( async, wait )
import "base" Control.Concurrent ( threadDelay )
import "base" Control.Monad ( forM_ )
import "base" Data.Functor ( void )
import "random" System.Random ( randomRIO )
import "terminal-progress-bar" System.ProgressBar

main :: IO ()
main = do
    example       60 (13 +  60) 25000
    exampleAsync  60 (13 +  60) 25000
    exampleAsync2    (13 + 100) 25000

example :: Integer -> Integer -> Int -> IO ()
example todo width delay = do
    forM_ [1 .. todo] $ \done -> do
      autoProgressBar percentage exact width $ Progress done todo
      threadDelay delay
    putStrLn ""

exampleAsync :: Integer -> Integer -> Int -> IO ()
exampleAsync todo width delay = do
    (pr, a) <- startProgress percentage exact width $ Progress 0 todo
    forM_ [1 .. todo] $ \_done -> do
      incProgress pr 1
      threadDelay delay
    wait a
    putStrLn ""

exampleAsync2 :: Integer -> Int -> IO ()
exampleAsync2 width delay = do
    (pr, a) <- startProgress percentage exact width $ Progress 0 todo
    -- Spawn some threads which each increment progress a bit.
    forM_ [1 .. numThreads] $ \_ ->
      void $ async $
        forM_ [1 .. progressPerThread] $ \_ -> do
          incProgress pr 1
          d <- randomRIO (delay * numThreads, 2 * delay * numThreads)
          threadDelay d

    -- Wait until the task is completed.
    wait a
    putStrLn ""
  where
    todo :: Integer
    todo = fromIntegral $ numThreads * progressPerThread

    numThreads :: Int
    numThreads = 10

    progressPerThread :: Int
    progressPerThread = 10
