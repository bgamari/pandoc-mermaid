{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.Text as T
import System.Process
import Text.Pandoc.JSON
import Control.Monad.Trans.State
import Control.Monad.IO.Class

main :: IO ()
main = evalStateT (toJSONFilter mermaidFilter) (0 :: Int)

mermaidFilter :: Block -> StateT Int IO Block
mermaidFilter (CodeBlock (_ident, classes, _kvs) content)
  | "mermaid":_ <- classes = do
      n <- get
      put (succ n)
      let format = "pdf"
      let out = "figure-"<>show n<>"."<>format
      -- from mermaid-cli
      let args = ["-i", "-", "--outputFormat", format, "--pdfFit", "-o", out]
      _ <- liftIO $ readProcess "mmdc" args (T.unpack content)
      return $ Plain [Image nullAttr [] (T.pack out, "")]
mermaidFilter blk = return blk

