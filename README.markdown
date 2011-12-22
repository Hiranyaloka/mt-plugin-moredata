# MOREDATA 0.14 FOR MOVABLE TYPE 4 AND MELODY #

MoreData parses finds and parses CSV strings from any Movable Type tag into a hash or array which can be captured as an MT variable. All with the single tag modifier, `moredata`.
   
## EMBEDDING THE DATA IN A TEXT FIELD ##

First embed a string anywhere within a text field accessible from an MT function tag. Let's use the EntryExcerpt field:

    Excerpt
    Here is my excerpt which I can output without the data.
    
    ---first_name=
    Moe,Larry,Curly
    
    ---last_name=
    Moe=>Howard,
    Curly=>Howard,
    Larry=>Fine
    
    ---say_yes=
    Why, certainly!
    ...
    
    And here is a continuation of the excerpt.
    
In your template, you can set an MT `string`, `array` or `hash` variable corresponding to one of the named strings (e.g. `say_yes` string, `first_name` array, `last_name` hash).

The `moredata` modifier accepts one or two arguments: The data identifier is the first argument, and an optional second, the format: (`array`, `hash`, or `string`). 
If no format is given, the blog default is used. You capture the data using the `setvar = whatever` argument.

You should review the Movable Type or Melody documentation of the `mt:Var` tag with arrays and hashes.

## SETTING THE VARIABLES IN YOUR TEMPLATES ##

    <mt:EntryExcerpt convert_breaks="0" moredata="first_name","array" setvar="first_name_a">
    <mt:EntryExcerpt convert_breaks="0" moredata="last_name","hash" setvar="last_name_h">
    <mt:EntryExcerpt convert_breaks="0" moredata="say_yes","string" setvar="say_yes_s">

__IMPORTANT:__ The `convert_breaks="0"` filter is important and should usually precede the `moredata` tag. This filter ensures that no extra formatting is inserted into your data by MT. If the text filter is set to `none` then you may not need to state explicitly.

## USING THE VARIABLES ##
Array via loop:

    <mt:Loop name="first_name_a">
      <mt:Var name="__value__">,   # gives Moe, Larry, Curly
    </mt:Loop>

Array by index:

    <mt:Var name="first_name_a[2]"> # gives Larry

Hash by loop:

    <mt:Loop name="last_name_h">
      <mt:Var name="__key__"> <mt:Var name="__value__">, # gives Moe Howard, Curly Howard, Lary Fine
    </mt:Loop>                                           # hash loops have their own special order

Hash by key:

    <mt:Var name="last_name_h{Moe}">  # gives Howard

The array index or hash key can be a variable. Here is a slightly sophisticated example, in which I loop through an array, using the array value as the key to a different hash variable.

    <mt:Loop name="first_name_a">
      <mt:Var name="first_name_a"> says, "I'm Dr. <mt:Var name="last_name_h{$first_name_a}">!<br />
    </mt:Loop>
    <br />
    Can we help you? <mt:Var name="say_yes_s"><br />


## RETRIEVING THE TAG CONTENT WITHOUT THE DATA ##
The content can be output separately with the `__content__` key:

    My content is: <mt:EntryExcerpt moredata="__content__">
    
Will output 

>> Here is my excerpt which I can output without the data. And here is a continuation of the excerpt.

For debugging or whatnot, the `__data__` key outputs the complete raw data string:

    My data is: <mt:EntryExcerpt convert_breaks="0" moredata="__data__">

This produces the full data string, including opentags, but without the close tag.

## BLOG-WIDE PLUGIN CONFIGURATION ##

The plugin takes five blog-wide settings:

- `opentag` should be a unique string which opens a data section, and is required for each data identifier.
- `closetag` is required at the end of the whole dataset. Optionally it can close each data section.
- `datasep` is a string that joins items in an array, and key-value pairs.
- `hashsep` is a string that joins keys from values.
- `format` is the default format, used when a second argument to the `moredata` modifier is not given.

## FORMATTING THE DATA ##

Each data section begins with an identifier, followed immediately by the data identifier and an equals sign:

    ---my_data=
    

Each named dataset must be terminated by another named dataset, or a closetag if it is the last, or by the end of the file:

    ---first=
    one,two,three
    ---second=
    snow=>white,ruby=>red
    ...
    
You can omit the close tag if the data is at the end of the content.
  
The named data sets must be in one contiguous block, and only one block is allowed.
(Everything between the first `opentag` and the `closetag` (or eof) is considered data).
You can put that data block in the middle of the content (but then don't forget the close tag).

## CHOOSING TAGS AND SEPARATORS ##
You can configure the open and close tags and the data and hash separator strings. The data separator and hash separator strings can be the same if you wish.
You need to be wary of potential conflicts between your open and close tags, the separators, and your content or data.

- Avoid having your open tags appearing in the preceding content or your close tags appearing in subsequent content.
- You don't want your data separators (`,`, `=>` etc) to appear in your data, obviously.
- You data identifiers can have spaces like `---first name=` or be empty `---=`

In the former you would use `moredata="first name"`. The latter would be `moredata=""`. But don't use the bareword `moredata` without at least one argument, even if it is the empty string.

##  RELATED PLUGINS ##
The venerable and awesome [Key Values plugin by Brad Choate](http://bradchoate.com/weblog/2002/07/27/keyvalues) was my inspiration for the MoreData plugin.

## SUPPORT ##
Please send questions, comments, or criticisms to rick@hiranyaloka.com. The 

## COPYRIGHT AND LICENSE ##

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

This software is offered "as is" with no warranty. 

MoreData is Copyright 2011, Rick Bychowski, rick@hiranyaloka.com.
All rights reserved.
