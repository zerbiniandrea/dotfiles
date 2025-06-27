function up --wraps='yay ; flatpak update' --description 'alias up=yay ; flatpak update'
  yay ; flatpak update $argv
        
end
