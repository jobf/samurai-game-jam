# Fushima's Curse

My submission to Samurai Game Jam, hosted on itch - https://cerealbuffer.itch.io/fushimas-curse

## how to build

### tool chain

You will need the following installed (other versions may work but this is what I used while developing the game):

 - haxe 4.3.3 - https://haxe.org/download/
 - lime 8.1.1 - https://lime.openfl.org/docs/home/

### libraries

The code relies on various other libraries. These are set up as git submodules so be sure to clone as follows:

```
git clone --recurse-submodules https://github.com/jobf/samurai-game-jam.git
```

### compile

You can now run the game:

```
cd samurai-game-jam
lime test html5
```
