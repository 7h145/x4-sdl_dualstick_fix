# X4 broken "duplicate identical joystick" SDL hack

The linux native version of [egosoft X4](https://www.egosoft.com/games/x4/info_en.php) can't cope with two identical joysticks due to a bug in the joystick enumeration in X4.  This rather old bug is still present in X4 7.50 beta (551247), [I've filed a fresh bug report](https://forum.egosoft.com/viewtopic.php?t=469177).

In the meantime, I'd really like to use my expensive toys... 

A long time ago, [Jasem Mutlaq files an X4 bug report](https://forum.egosoft.com/viewtopic.php?p=4954066#p4954066) and crucially [came up with a patch for libSDL2](https://github.com/libsdl-org/SDL/issues/3686) to mitigate the problem on the libSDL side (which did not make it into libSDL proper since it's kind of a crude hack to workaround a bug in X4).  All kudos to him, thanks Jasem!

This is just Jasem Mutlaqs patch rebased to libSDL 2.30.11 and packaged in a convenient container for building.

## Building the patched libSDL

The `Containerfile` builds the whole shebang at container build time, so just...

    podman build -t x4sdlfix:latest .

to build image with a fresh `libSDL2*.so*` shared library in the `/stage` directory in the container.  After that something to the effect of

    podman run -v ${PWD}:/tmp -it --rm x4sdlfix bash -c 'cp -v /stage/libSDL2* /tmp'

to get the newly build patched `libSDL2*.so*` library into `$PWD`.  You may delete the `x4sdlfix` container image afterwards of course (e.g. `podman image rm x4sdlfix:latest`).


## Installing the patched libSDL

Just replace the `libSDL2-2.0.so.0` in `X4 Foundations/lib` with the patched `libSDL2*.so*`, e.g.

    X4APPDIR='/path/to/X4\ Foundations'

    mv -v "${X4APPDIR}/lib"/libSDL2-2.0.so.0{,.dist}
    cp libSDL2*.so* "${X4APPDIR}/lib/libSDL2-2.0.so.0"

Or something nicer with popper named symlinks if you fancy.

## Remarks

 * As said above, this is a hack in libSDL to workaround a bug in X4.  I really wouldn't use this in any other context.

 * I don't know wich version of libSDL is used by egosoft to build the current X4 version; Jasem bug report is from 2020, maybe against libSDL 2.0.12.

   The contemporary versions of libSDL (like 2.30.11) do introduce a set of interesting new SDL quirks to X4, replacing the original ones from the egosoft version.  I like the new quirks more than the old ones, but your mileage may vary.

 * I do set [`SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0`](https://wiki.libsdl.org/SDL2/SDL_HINT_VIDEO_MINIMIZE_ON_FOCUS_LOSS), which mimics the behaviour of egosofts libSDL (i.e. `SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0 %command%` in the Steam launch options).  This should actually be the default in libSDL, but it is obviously not.

