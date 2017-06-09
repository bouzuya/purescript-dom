module Test.DOM.Node.DOMTokenList where

import Prelude

import Control.Monad.Aff.Console (CONSOLE)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Free (Free)
import DOM (DOM)
import DOM.HTML (window)
import DOM.HTML.Document (body)
import DOM.HTML.HTMLElement (classList, className, setClassName)
import DOM.HTML.Types (WINDOW)
import DOM.HTML.Window (document)
import DOM.Node.ClassList (add, contains, remove, toggle, toggleForce, item) as CL
import Data.Maybe (Maybe(..), fromMaybe)
import Test.Unit (TestF, describe, it)
import Test.Unit.Assert (shouldEqual)

domTokenListTests :: forall eff. Free (TestF (dom :: DOM, console :: CONSOLE,
  window :: WINDOW | eff)) Unit
domTokenListTests = do
  describe "DOMTokenList of classList" do
    it "contains a token" do
      body' <- liftEff $ window >>= document >>= body
      result <- case body' of
                  Just body'' -> liftEff do
                    _ <- setClassName "a b c" body''
                    list <- classList body''
                    CL.contains "a" list
                  Nothing -> pure false

      result `shouldEqual` true

    it "adds a token" do
      body' <- liftEff $ window >>= document >>= body
      result <- case body' of
                  Just body'' -> liftEff do
                    -- clear class names, first
                    _ <- setClassName "" body''
                    list <- classList body''
                    _ <- CL.add "a" list
                    className body''
                  Nothing -> pure "failed"

      result `shouldEqual` "a"

    it "removes a token" do
      body' <- liftEff $ window >>= document >>= body
      result <- case body' of
                  Just body'' -> liftEff do
                    _ <- setClassName "a b c" body''
                    list <- classList body''
                    _ <- CL.remove "b" list
                    resultA <- CL.contains "a" list
                    resultB <- CL.contains "b" list
                    resultC <- CL.contains "c" list
                    -- Only "b" should be removed
                    pure $ resultA && not resultB && resultC
                  Nothing -> pure false

      result `shouldEqual` true

    it "toggles a token by removing its value" do
      body' <- liftEff $ window >>= document >>= body
      result <- case body' of
                  Just body'' -> liftEff do
                    _ <- setClassName "a b c" body''
                    list <- classList body''
                    _ <- CL.toggle "c" list
                    className body''
                  Nothing -> pure "failed"

      result `shouldEqual` "a b"

    it "toggles a token by adding its value" do
      body' <- liftEff $ window >>= document >>= body
      result <- case body' of
                  Just body'' -> liftEff do
                    _ <- setClassName "a b" body''
                    list <- classList body''
                    _ <- CL.toggle "c" list
                    className body''
                  Nothing -> pure "failed"

      result `shouldEqual` "a b c"

    it "toggles a token by forcing to add its value" do
      body' <- liftEff $ window >>= document >>= body
      result <- case body' of
                  Just body'' -> liftEff do
                    _ <- setClassName "a b" body''
                    list <- classList body''
                    _ <- CL.toggleForce "c" true list
                    className body''
                  Nothing -> pure "failed"

      result `shouldEqual` "a b c"

    it "toggles a token by forcing to add (but not to remove) its value" do
      body' <- liftEff $ window >>= document >>= body
      result <- case body' of
                  Just body'' -> liftEff do
                    _ <- setClassName "a b c" body''
                    list <- classList body''
                    _ <- CL.toggleForce "c" true list
                    className body''
                  Nothing -> pure "failed"

      result `shouldEqual` "a b c"

    it "toggles a token by forcing to remove its value" do
      body' <- liftEff $ window >>= document >>= body
      result <- case body' of
                  Just body'' -> liftEff do
                    _ <- setClassName "a b c" body''
                    list <- classList body''
                    _ <- CL.toggleForce "c" false list
                    className body''
                  Nothing -> pure "failed"

      result `shouldEqual` "a b"

    it "toggles a token by forcing to remove (but not to add) its value" do
      body' <- liftEff $ window >>= document >>= body
      result <- case body' of
                  Just body'' -> liftEff do
                    _ <- setClassName "a b" body''
                    list <- classList body''
                    _ <- CL.toggleForce "c" false list
                    className body''
                  Nothing -> pure "failed"

      result `shouldEqual` "a b"

    it "returns an item if available" do
      body' <- liftEff $ window >>= document >>= body
      result <- case body' of
                  Just body'' -> liftEff do
                    _ <- setClassName "a b c" body''
                    list <- classList body''
                    CL.item 2 list
                  Nothing -> pure Nothing

      (fromMaybe "not found" result) `shouldEqual` "c"

    it "returns not an item if it's not available" do
      body' <- liftEff $ window >>= document >>= body
      result <- case body' of
                  Just body'' -> liftEff do
                    _ <- setClassName "a b c" body''
                    list <- classList body''
                    CL.item 5 list
                  Nothing -> pure Nothing

      (fromMaybe "not found" result) `shouldEqual` "not found"
