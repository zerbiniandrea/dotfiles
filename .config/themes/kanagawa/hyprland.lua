hl.config({ general = { col = { active_border = "rgb(dcd7ba)" } } })

-- Kanagawa backdrop is too strong for default opacity
hl.window_rule({ match = { tag = "terminal" }, opacity = "0.98 0.95" })
