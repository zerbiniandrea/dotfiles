#!/usr/bin/env python3
import gi
gi.require_version("Playerctl", "2.0")
from gi.repository import Playerctl, GLib
from gi.repository.Playerctl import Player
import argparse
import logging
import sys
import signal
import gi
import json
import os
from typing import List

logger = logging.getLogger(__name__)

def signal_handler(sig, frame):
    logger.info("Received signal to stop, exiting")
    sys.stdout.write("\n")
    sys.stdout.flush()
    # loop.quit()
    sys.exit(0)


class PlayerManager:
    def __init__(self, selected_player=None, excluded_player=[]):
        self.manager = Playerctl.PlayerManager()
        self.loop = GLib.MainLoop()
        self.manager.connect(
            "name-appeared", lambda *args: self.on_player_appeared(*args))
        self.manager.connect(
            "player-vanished", lambda *args: self.on_player_vanished(*args))

        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
        signal.signal(signal.SIGUSR1, self.cycle_player)
        self.selected_player = selected_player
        self.excluded_player = excluded_player.split(',') if excluded_player else []
        self.current_player_index = 0
        self.state_file = "/tmp/waybar_media_player_index"

        self.load_player_index()
        self.init_players()

    def load_player_index(self):
        try:
            if os.path.exists(self.state_file):
                with open(self.state_file, 'r') as f:
                    self.current_player_index = int(f.read().strip())
        except:
            self.current_player_index = 0

    def save_player_index(self):
        try:
            with open(self.state_file, 'w') as f:
                f.write(str(self.current_player_index))
        except:
            pass

    def cycle_player(self, signum, frame):
        players = self.get_players()
        if len(players) > 1:
            self.current_player_index = (self.current_player_index + 1) % len(players)
            self.save_player_index()
            self.show_current_player()

    def get_current_player(self):
        players = self.get_players()
        if len(players) == 0:
            return None
        # Ensure index is within bounds
        if self.current_player_index >= len(players):
            self.current_player_index = 0
            self.save_player_index()
        return players[self.current_player_index]

    def init_players(self):
        for player in self.manager.props.player_names:
            if player.name in self.excluded_player:
                continue
            if self.selected_player is not None and self.selected_player != player.name:
                logger.debug(f"{player.name} is not the filtered player, skipping it")
                continue
            self.init_player(player)

    def run(self):
        logger.info("Starting main loop")
        # Show initial state
        self.show_current_player()
        self.loop.run()

    def init_player(self, player):
        logger.info(f"Initialize new player: {player.name}")
        player = Playerctl.Player.new_from_name(player)
        player.connect("playback-status",
                       self.on_playback_status_changed, None)
        player.connect("metadata", self.on_metadata_changed, None)
        self.manager.manage_player(player)
        self.on_metadata_changed(player, player.props.metadata)

    def get_players(self) -> List[Player]:
        return self.manager.props.players

    def write_output(self, text, player):
        logger.debug(f"Writing output: {text}")
        
        # Save current player name for shell script
        try:
            with open("/tmp/waybar_current_player_name", 'w') as f:
                f.write(player.props.player_name)
        except:
            pass
        
        players = self.get_players()
        if len(players) > 1:
            # Show arrows around the entire content if multiple players
            if text:
                # Smart truncation: ensure closing > is always visible
                max_content_length = 37  # 40 total - 3 for "< >"
                if len(text) > max_content_length:
                    text = text[:max_content_length-3] + "..."
                text = f"< {text} >"
            else:
                text = "< >"
        
        output = {"text": text,
                  "class": "custom-" + player.props.player_name,
                  "alt": player.props.player_name}

        sys.stdout.write(json.dumps(output) + "\n")
        sys.stdout.flush()

    def clear_output(self):
        sys.stdout.write("\n")
        sys.stdout.flush()

    def on_playback_status_changed(self, player, status, _=None):
        logger.debug(f"Playback status changed for player {player.props.player_name}: {status}")
        self.on_metadata_changed(player, player.props.metadata)

    def get_first_playing_player(self):
        players = self.get_players()
        logger.debug(f"Getting first playing player from {len(players)} players")
        if len(players) > 0:
            # if any are playing, show the first one that is playing
            # reverse order, so that the most recently added ones are preferred
            for player in players[::-1]:
                if player.props.status == "Playing":
                    return player
            # if none are playing, show the first one
            return players[0]
        else:
            logger.debug("No players found")
            return None

    def show_current_player(self):
        logger.debug("Showing current selected player")
        current_player = self.get_current_player()
        if current_player is not None:
            self.on_metadata_changed(current_player, current_player.props.metadata)
        else:    
            self.clear_output()

    def on_metadata_changed(self, player, metadata, _=None):
        logger.debug(f"Metadata changed for player {player.props.player_name}")
        player_name = player.props.player_name
        artist = player.get_artist()
        title = player.get_title()

        track_info = ""
        if player_name == "spotify" and "mpris:trackid" in metadata.keys() and ":ad:" in player.props.metadata["mpris:trackid"]:
            track_info = "Advertisement"
        elif artist is not None and title is not None:
            track_info = f"{artist} - {title}"
        else:
            track_info = title

        if track_info:
            if player.props.status == "Playing":
                track_info = "  " + track_info
            else:
                track_info = "  " + track_info
        # only print output if this is the currently selected player
        current_selected = self.get_current_player()
        if current_selected is not None and current_selected.props.player_name == player.props.player_name:
            self.write_output(track_info, player)
        else:
            logger.debug(f"Player {player.props.player_name} is not the selected player, skipping")

    def on_player_appeared(self, _, player):
        logger.info(f"Player has appeared: {player.name}")
        if player.name in self.excluded_player:
            logger.debug(
                "New player appeared, but it's in exclude player list, skipping")
            return
        if player is not None and (self.selected_player is None or player.name == self.selected_player):
            self.init_player(player)
            self.show_current_player()  # Update display when new player appears
        else:
            logger.debug(
                "New player appeared, but it's not the selected player, skipping")

    def on_player_vanished(self, _, player):
        logger.info(f"Player {player.props.player_name} has vanished")
        # Reset index if it's out of bounds
        players = self.get_players()
        if self.current_player_index >= len(players):
            self.current_player_index = max(0, len(players) - 1)
            self.save_player_index()
        self.show_current_player()

def parse_arguments():
    parser = argparse.ArgumentParser()

    # Increase verbosity with every occurrence of -v
    parser.add_argument("-v", "--verbose", action="count", default=0)

    parser.add_argument("-x", "--exclude", "- Comma-separated list of excluded player")

    # Define for which player we"re listening
    parser.add_argument("--player")

    parser.add_argument("--enable-logging", action="store_true")

    return parser.parse_args()


def main():
    arguments = parse_arguments()

    # Initialize logging
    if arguments.enable_logging:
        logfile = os.path.join(os.path.dirname(
            os.path.realpath(__file__)), "media-player.log")
        logging.basicConfig(filename=logfile, level=logging.DEBUG,
                            format="%(asctime)s %(name)s %(levelname)s:%(lineno)d %(message)s")

    # Logging is set by default to WARN and higher.
    # With every occurrence of -v it's lowered by one
    logger.setLevel(max((3 - arguments.verbose) * 10, 0))

    logger.info("Creating player manager")
    if arguments.player:
        logger.info(f"Filtering for player: {arguments.player}")
    if arguments.exclude:
        logger.info(f"Exclude player {arguments.exclude}")

    player = PlayerManager(arguments.player, arguments.exclude)
    player.run()


if __name__ == "__main__":
    main()
