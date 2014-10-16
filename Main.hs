module Main where

import Control.Monad hiding (forM_)
import Control.Monad.Random
import Engine.SDL.Basic
import Engine.SDL.Video
import Engine.Var
import Foreign
import Foreign.C
import System.Exit
import Graphics.Rendering.OpenGL as GL hiding (doubleBuffer)
import Graphics.Rendering.OpenGL.Raw as GL
import Graphics.UI.SDL.Enum  as SDL
import Graphics.UI.SDL.Event as SDL
import Graphics.UI.SDL.Types as SDL
import Graphics.UI.SDL.Video as SDL
import Prelude hiding (init)

main :: IO ()
main = withCString "engine" $ \windowName -> do
  ver <- version
  putStr $ "SDL2 " ++ show ver
  init initFlagEverything
  contextMajorVersion &= 4
  contextMinorVersion &= 1
  contextProfileMask  &= glProfileCore
  redSize   &= 5
  greenSize &= 5
  blueSize  &= 5
  depthSize &= 16
  doubleBuffer &= True
  window <- createWindow windowName windowPosUndefined windowPosUndefined 1024 768 (windowFlagOpenGL .|. windowFlagShown .|. windowFlagResizable .|. windowFlagAllowHighDPI)
  _ <- glCreateContext window
  glEnable gl_FRAMEBUFFER_SRGB
  forever (poll >> render window)

render :: Window -> IO ()
render window = do
  r <- randomIO
  clearColor $= Color4 r 0 0 1
  clear [ColorBuffer, StencilBuffer, DepthBuffer]
  glSwapWindow window

shutdown :: IO ()
shutdown = quit >> exitSuccess

poll :: IO ()
poll = alloca go where
  go ep = pollEvent ep >>= \ r -> when (r /= 0) $ do
    peek ep >>= handleEvent
    go ep

handleEvent :: SDL.Event -> IO ()
handleEvent QuitEvent{}                                                    = shutdown
handleEvent KeyboardEvent{keyboardEventKeysym=Keysym{keysymKeycode = 27 }} = shutdown
handleEvent e = print e