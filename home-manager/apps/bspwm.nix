{
  #BSPWM
  xsession.windowManager.bspwm.enable = true;
  xsession.windowManager.bspwm.monitors	= {
  HDMI-1 = [
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
      "8"
      "9"
      ];
	};

  xsession.windowManager.bspwm.settings = {
      border_width = 1;
      window_gap = 10;
      normal_border_color = "#44475a";
      active_border_color = "#6272a4";
      focused_border_color = "#8be9fd";
      presel_feedback_color = "#6272a4";
      pointer_follows_focus = false;
      focus_follows_pointer = true;
      split_ratio = 0.50;
      borderless_monocle = true;
      gapless_monocle = true;
	};

  xsession.windowManager.bspwm.rules = {
	"Nm-connection-editor" = {
      state = "floating";
    };
	"Galculator" = {
      state = "floating";
    };
	"firefox" = {
      desktop = "^2";
      follow = true;
      };
	};

  xsession.windowManager.bspwm.startupPrograms = [
    #/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
    "/home/craig/nixos-workpc/scripts/screen.sh"
    "nitrogen --restore"
    "/home/craig/.config/polybar/launch.sh"
    "picom"
    "nm-applet"
    "volumeicon"
    "udiskie -t"
    "flameshot"
    "xsetroot -cursor_name left_ptr"
    ];
}
