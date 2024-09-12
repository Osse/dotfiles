from typing import Any, Dict

from kitty.boss import Boss
from kitty.window import Window, DynamicColor

def on_focus_change(boss: Boss, window: Window, data: Dict[str, Any])-> None:
    if data["focused"]:
        boss.call_remote_control(window, ('set-colors', 'background=#121212'))
    else:
        boss.call_remote_control(window, ('set-colors', 'background=black'))
