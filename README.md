# Rayuela Jam

This is our game for Rayuela de Arena Jam, a visual novel featuring some minigames.
The dialogues are in Spanish, since the jam is focused in Spanish-speaking narrative games.

## Special thanks

We have used freely available graphics from other artists. These are:

- Dialogboxes: by [CharlesGabriel](https://opengameart.org/content/10-basic-message-boxes)
- Tuxemon Tilset: by [Buch](http://blog-buch.rhcloud.com)
- Dungeon Tileset: by [DignifiedRain](https://opengameart.org/content/16bit-dungeon-tiles)
- Space Background: by [ansimuz](https://opengameart.org/content/space-background-3)
- Backgrounds: CC0 edited images, some of them with no specified artist.


**IMPORTANT: These files have their own licenses. Please read them carefully if you want to reuse them**


# Simple Dialogue Metalanguage

This is a simple dialogue metalanguage, developed to be the main engine of our visual novel, presented for the game jam _Rayuela de Arena_, a jam about narrative in Spanish.

The metalanguage has easy integration in any project and be very useful to make simple visual novels in Godot Engine 3, as well as cutscenes and dialogues for the characters in your games. This page explains the syntax of the language.

## Set up graphics

Open the `vn_engine` folder and open the `ginfo` file. All the paths to the different graphics you want to use have to be written here. The syntax is the following:

```
#PREFIX;/path/to/graphics/folder/
metaname1; ch_name1; file1.png; offsetX; offsetY; scale
metaname2; ch_name2; this/is/inside/a/folder/file2.png; offsetX; offsetY; scale
...
metanameN; ch_nameN; fileN.png; offsetX; offsetY; scale
```

The first line allows you to declare the root folder where your graphics are located, so you don't have to write for each single file. This line is optional and you can skip it if you want. In the next files, you map a _metaname_ to a character name and a graphic file. The metaname will be the identifier used for the visual novel engine, and the character name the one displayed in the dialogboxes.
Finally, the `offsetX` and `offsetY` variable allows you to move the position of the slot, in order to correct little problems with your graphics. You also can change the size with the `scale` (1.0 means no resize). These arguments are optional, so the following is valid syntax:

```
#Assumes offset=(0,0) and scale=1
metaname1; ch_name1; file1.png
#Assumes offset=(x,y) and scale=1
metaname; ch_name1; file1.png; x; y
```

> Take in account that `metaname; ch_name; file.png; scale` is **not** valid syntax. If you want to specify the scale, `offset` must be provided.

The dialogbox graphic can be edited simply editing the `dialogbox.tscn` scene. Take care of its corresponding script when doing this.

## The Metalanguage

Now we go for the metalanguage. The parser will start always in the file `main`, situated in the `vn_engine` folder. The most common task now is to tell this file to jump to whatever place you want:

```
jump;   res://visual_novel/startpoint.txt
```

Here we can see the basic syntax of the metalanguage: **each line is a different command, and all arguments are separated by `;`**. Keep this in mind when writing the code. The `jump` command will simply stop parsing the current file and start parsing the new one from the beginning. It is useful to keep the main branches or chapters of your visual novel well organized.

A line that starts with `#` is considered a commentary and ignored by the parser. However, take in account that something like

```
jump; res://visual_novel/startpoint.txt #Move to starting point
```

will result in an error from the parser. Commentaries are only one-line commentaries.

### Showing characters

The first thing is to load the characters into memory. You can use as many textures as you want, but you need to load them first into memory. This is because a visual novel may contain a large amount of decent size textures. The engine have support for only 4 characters in screen. Each texture will have a slot assigned. The syntax is like this:

```
load; metaname1; metaname2; ...; metanameN;
```

As you see, we use the `load` command and then we use the metanames (those we defined in the `ginfo` file) to load the textures. We remark that we can load up to four textures in this way. The slots, however, will be still empty. In order to show the textures, we use the `show` command:

```
load; metaname1; metaname2; metaname3;
show; metaname1; 1; true
show; metaname3; 2; true
```

This command shows the texture corresponding to the `metaname1` at slot 1, and the one corresponding to `metaname2` to slot 2. The order of slots in screen is like this: `1 3 4 2`. The last argument tells the engine to use a fade-in effect when set to `true`. It is optional and its default value is `false`, so you can change the expression of your characters without any fade.
We can hide the character of any slot via 

```
hide; slot_index
```

This will make the texture to fade out.

### Fades and transitions

It is possible to change the background of the scene via

```
set_bg; bgmetaname
```

Where the bgmetaname must be previously declared in the `ginfo` file, as the characters. Note that the name for the background textures is completely irrelevant.
However, this will automatically change the texture. We make do a smoother transition using a fade-out-in transition:

```
fade_out;
set_bg; bgmetaname
fade_in;
```

The `fade_out` command expects the player to press the button to continue. The transition can be used also with the `load_scene` or `jump`commands to create smoother transitions!

### Dialogues

Making dialogues is as easy as writing the slot number of the speaker and then the text. All the text must be written in one line (i.e. without pressing `enter`). Linebreaks in the dialogue may be introduced with `\n`.

```
1; How are you?
2; Very well. \nWhat about you?
``` 

BBCode may be introduced to use italics, bolds, or color:

```
1; How are you?
2; Very well. \nWhat about [color=red]you[/color]?
``` 

### Tags and branching

Any line of the code may be **tagged**. This will allow the metalanguage to jump to this line later. A tag is a line that starts with `%`. The identifier of the tag may be whatever you want, without spaces. For example:

```
%mytag
%100
%myTag_100
```

You can jump to a tagged line with `goto`. The position of the tag in the file does not matter, `goto` will always jump to it. 

```
%back
1; This is an infinite loop
1; Do you like it?
goto; back
```

The next step is to introduce branching and decisions in the code. This can be done with the `do_branch` command. When executed, this command show a list of optins to player (maximum four). Depending on the player's choice, the code will jump to a different tag, as specified. The syntax is:

```
do_branch; noptions; text1; tag1; text2; tag2; ... 
```

In this command, `noptions` is the number of options that will be presented to the player. Four is the maximum (since each option has one line lenght, and the dialogbox has capacity for four lines). Then, for each option, we must include the text that will be presented to the player, and the tag corresponding for this choice. For example,


```
2; Do you want to come tomorrow?
#Extra space to make clear option-tag syntax
do_branch; 2;   Yes, of course; Y;   No, I don't; N  

%Y
2; Nice! I will see you there
goto; MEETING

%N
2; Oh! What a shame!
```

Combinations of the `do_branch`, `goto` and `jump` commands can create rich situations with practically no effort!

### Variables and conditionals

It is possible also two work with **integer** variables. There are two different commands for this: `set` is used to declare a variable and/or sets its value, while `add` modifies it by its value by the specified amount:

```
set; my_variable; 10
add; my_variable; 3 
add; my_variable; -1
``` 

At the end, `my_variable` has value `12`. It is possible to take decisions depending on the value of the variables, using an `if` command. The syntax is:

```
if; cond; tag_true; tag_false
```

In this command, `cond` is something like `my_variable == 2` or `my_variable > -1`. Valid operators for comparisons are `==`, `!=`, `>=`, `>`, `<=` and `<`. If the condition is true, the code jumps to the tag `tag_true`. In other case, jumps to `tag_false`. For example, a simple shop:


```
2; Do you want to buy this?
if; money > 5; BUY; NO;

%BUY
2; Thank you very much!
goto; GOODBYE

%NO
2; You don't have enough money for this!

%GOODBYE
2; Thank you very much, goodbye!
``` 

The variables and the `if` command, combined with `goto` and branches is a powerful way to add interactive behaviour to your novel.

> Moreover, if you are using the engine as a code to tell the story of any game (for example, dialogues in a JRPG), variables can be even more interesting. 
> You can edit the variables of the metalanguage in your Godot name, simply doing a call to the AutoLoad script `vnglobal`. Take the following example as a reference:

```
#(...)
#GDSCRIPT:
func give_scepter():
    vnglobal = get_tree().root.get_node("/root/vn_global")
    vnglobal.set_var("has_scepter", 1)

#(...)
#VISUAL NOVEL METALANGUAGE

if; has_scepter==1; SCEPTER_SCENE; DEATH_SCENE

%SCEPTER_SCENE
#(...)
goto; DEATH_SCENE


%DEATH_SCENE
#(...)

```
> With this script, you can change the conversations between characters depending on the result of one of the in-game battles (in Godot). This is very useful in many situations. Take in account that `vnglobal.add_var(name, value)` is also available.


### Some comments

When a file ends, an error raise. It is mandatory to jump to another file, as the last command of a file. In addition to this, it is possible to load another scene of your game, meaning it is the end of your cutscene:

```
load_scene; res://path/to/scene.tscn
```

Finally the behaviour of the engine can be improved a lot. Only the most basic functionality is implemented. Any interesting addition can be considered!









