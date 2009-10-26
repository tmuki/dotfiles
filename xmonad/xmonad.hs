import XMonad
import XMonad.Operations
import XMonad.Actions.DwmPromote
import XMonad.Hooks.DynamicLog   ( PP(..), dynamicLogWithPP, dzenColor, xmobarColor, wrap, shorten, defaultPP )
import XMonad.Layout
import XMonad.Layout.NoBorders
import XMonad.Prompt             ( XPConfig(..), XPPosition(..) )
import XMonad.Prompt.Shell       ( shellPrompt )
import XMonad.Util.Run
import XMonad.Hooks.ManageDocks
 
import qualified Data.Map as M
import Data.Bits ((.|.))
import Data.Ratio
import Graphics.X11                                                                                                    
import System.IO
 
--statusBarCmd= "dzen2 -bg '#2c2c32' -fg 'grey70' -w 730 -sa c -fn '-*-profont-*-*-*-*-11-*-*-*-*-*-iso8859' -e '' -xs 1 -ta l"
statusBarCmd= "xmobar"
 
main = do din <- spawnPipe statusBarCmd
          xmonad $ defaultConfig
                     { borderWidth        = 1
                     , normalBorderColor  = "grey30"
                     , focusedBorderColor = "#aecf96" 
                     , workspaces         = ["1:web", "2:mail", "3:dev", "4:media", "5:tmp", "6:tmp"] 
                     , terminal           = "urxvt"
                     , modMask            = mod4Mask
                     , manageHook         = manageDocks
                     , logHook            = dynamicLogWithPP $ robPP din
                     , layoutHook         = avoidStruts (tiled ||| Mirror tiled ||| noBorders Full)
                     , keys               = \c -> robKeys `M.union` 
                                                  keys defaultConfig c 
                     }
                     where
                       tiled = Tall 1 (3%100) (1%2)
 
 
-- redifine some keys
--
robKeys = M.fromList $
   [ ((mod4Mask     , xK_p      ), shellPrompt robSPConfig)
   , ((mod4Mask     , xK_c      ), spawn "/home/tmak/bin/dzencal.sh")
   , ((mod4Mask     , xK_Return ), dwmpromote)
   , ((mod4Mask     , xK_b      ), sendMessage ToggleStruts)
 
   -- multimedia keys
   --
   -- XF86AudioLowerVolume
   , ((0            , 0x1008ff11), spawn "aumix -v -2")
   -- XF86AudioRaiseVolume
   , ((0            , 0x1008ff13), spawn "aumix -v +2")
   -- XF86AudioMute
   , ((0            , 0x1008ff12), spawn "amixer -q set PCM toggle")
   -- XF86AudioNext
   , ((0            , 0x1008ff17), spawn "mocp -f")
   -- XF86AudioPrev
   , ((0            , 0x1008ff16), spawn "mocp -r")
   -- XF86AudioPlay
   , ((0            , 0x1008ff14), spawn "mocp -G")
   ]
 

-- dynamiclog pretty printer for xmobar
--
robPP h = defaultPP 
                 {  ppHidden = xmobarColor "#00FF00" ""
                  , ppCurrent = xmobarColor "#FF0000" "" . wrap "[" "]"
                  , ppUrgent = xmobarColor "#FF0000" "" . wrap "*" "*"
                  , ppLayout = xmobarColor "#FF0000" ""
                  , ppTitle = xmobarColor "#00FF00" "" . shorten 80
                  , ppSep = "<fc=#0033FF> | </fc>"
                  , ppOutput = hPutStrLn h
                  }
 
-- dynamiclog pretty printer for dzen
--
--robPP h = defaultPP 
--                 { ppCurrent = wrap "^fg(#000000)^bg(#a6c292)^p(2)^i(/home/tmak/.dzen_bitmaps/has_win.xbm)" "^p(2)^fg()^bg()"
--                  , ppVisible = wrap "^bg(grey30)^fg(grey75)^p(2)" "^p(2)^fg()^bg()"
--                  , ppSep     = " ^fg(grey60)^r(3x3)^fg() "
--                  , ppLayout  = dzenColor "#80AA83" "" .
--                                (\x -> case x of
--                                         "Tall" -> "^i(/home/tmak/.dzen_bitmaps/tall.xbm)"
--                                         "Mirror Tall" -> "^i(/home/tmak/.dzen_bitmaps/mtall.xbm)"
--                                         "Full" -> "^i(/home/tmak/.dzen_bitmaps/full.xbm)"
--                                )
--                  , ppTitle   = dzenColor "white" "" . wrap "< " " >" 
--                  , ppOutput   = hPutStrLn h
--                  }

-- shellprompt config
--
robSPConfig = XPC { 
                           font              = "-*-profont-*-*-*-*-11-*-*-*-*-*-iso8859"
                         , bgColor           = "#111111"
                         , defaultText       = ""
                         , fgColor           = "#d5d3a7"
                         , bgHLight          = "#aecf96"
                         , fgHLight          = "black"
                         , borderColor       = "black"
                         , promptBorderWidth = 0
                         , position          = Bottom
                         , height            = 15
                         , historySize       = 256
                         , autoComplete      = Nothing
                   }
