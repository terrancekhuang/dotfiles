# Start Hyprland through UWSM (automatic)
if uwsm check may-start; then
	exec uwsm start hyprland.desktop
fi
