# Fusuma::Plugin::Sendkey [![Gem Version](https://badge.fury.io/rb/fusuma-plugin-sendkey.svg)](https://badge.fury.io/rb/fusuma-plugin-sendkey) [![Build Status](https://travis-ci.com/iberianpig/fusuma-plugin-sendkey.svg?branch=master)](https://travis-ci.com/iberianpig/fusuma-plugin-sendkey)

[Fusuma](https://github.com/iberianpig/fusuma) plugin to send keyboard events

* Low-latency key event emulation with evdev
* Alternative to xdotool available for X11 and Wayland

## Installation

Run the following code in your terminal.

### Install dependencies

**NOTE: If you have installed ruby by apt, you must install ruby-dev.**
```sh
$ sudo apt-get install libevdev-dev ruby-dev
```

### Install fusuma-plugin-sendkey

```sh
$ sudo gem install fusuma-plugin-sendkey
```


## List available keys

```sh
$ fusuma-sendkey -l
```
If you want to look up a specific key, like the next song or the previous song, the `grep -i` refinement search is useful.

```sh
$ fusuma-sendkey -l | grep -i song
NEXTSONG
PREVIOUSSONG
```

## Run fusuma-sendkey on Terminal

* `fusuma-sendkey` command is available on your terminal
* `fusuma-sendkey` supports modifier keys and multiple key presses.
Combine keys for pressing the same time with `+` 


```sh
$ fusuma-sendkey LEFTCTRL+T # press ctrl key + t key
```

Some of the keys found with `fusuma-sendkey -l` may actually be invalid keys.
So test it once with `fusuma-sendkey <KEYCODE>` and then add it to config.yml.


## Add sendkey properties to config.yml

Add `sendkey:` property in `~/.config/fusuma/config.yml`.

lines beginning from `#` are comments

```yaml
swipe:
  3:
    left:
      sendkey: "LEFTALT+RIGHT" # history back
    right:
      sendkey: "LEFTALT+LEFT" # history forward
    up:
      sendkey: "LEFTCTRL+T" # open new tab
    down:
      sendkey: "LEFTCTRL+W" # close tab
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iberianpig/fusuma-plugin-sendkey. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Fusuma::Plugin::Sendkey project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/iberianpig/fusuma-plugin-sendkey/blob/master/CODE_OF_CONDUCT.md).
