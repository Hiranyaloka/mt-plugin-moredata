# MOREDATA 0.81 FOR MOVABLE TYPE 4, 5, AND MELODY #

MoreData parses finds and parses CSV strings from any Movable Type tag into a hash, array, or string which can be captured as an MT variable.

The MoreData plugin provides a `moredata` tag modifier for extracting structured data from any function tag (i.e. any tag which outputs text).

MoreData also provides an Entry/Page custom text field (cleverly called `MoreData`) for loading with as many data structures as you need: hashes, arrays, and strings. And of course the `moredata` modifier works very nicely with the `MoreData` custom field tag.

    <mt:MoreData moredata="foo","hash" setvar="my_foo_hash"> # We'll clarify this shortly
    
A blog-scoped custom field `MoreDataBlog` allows MoreData data to be configured within the MoreData plugin settings panel. For example, to set a folder list for creating a navigation bar:

    <mt:MoreDataBlog moredata="folder_ids","array" setvar="nav_folders">
    
Or to simply specifiy a banner image:

    <mt:MoreDataBlog moredata="banner_image_id","string" setvar="banner_image_id">
    
As with the Entry/Page-scoped `MoreData` field, the `MoreDataBlog` field holds as many data structures as you require.
   
## EMBEDDING THE DATA IN A TEXT FIELD ##

While the `MoreData` and `MoreDataBlog` fields are perhaps the most convenient places to place your MoreData data, you can embed a string inside any text field accessible from an MT function tag (e.g. EntryExcerpt AssetDescription, and CategoryDescription are all good.) Avoid the body and extended fields, as the 'rich text' or MarkDown formatting may mangle your data.

To provide a convenient place to stash your MoreData data strings, the plugin also provides the `MoreData` custom field available within your Entries and Pages, and the `MoreDataBlog` field found in the plugin settings panel. These fields are referenced by the `MoreData` and `MoreDataBlog` tags, respectively.

The strings within each named data block are processed by Text::CSV, set to allow double quoted strings and whitespace. So you can use standard CSV syntax. Let's consider an example of an array (named locations) with three items. We place the following text into an Entry `MoreData` field:

    ---locations=
    "Chicago, Illinois", "San Diego, California", "New York, New York"
    ...

And a hash with three elements:    

    ---nicknames=
    "Walter Payton" = "Sweetness"
    "William Perry" = "Refrigerator"
    "Michael Singletary" = "Iron Mike"
    ...

Let's demonstrate how to use the data. First add the following text to the MoreData (or whichever) field:

    Here is my excerpt which I can output without the data.
    
    ---first_name=
    Moe, Larry, Curly
    
    ---last_name=
    Moe = Howard
    Curly = Howard
    Larry = Fine
    
    ---say_yes=
    Why, certainly!
    ...
    
    And here is a continuation of the excerpt.
    
The above text field has two parts:

- The data section starts with the _first_ open tag (in this case `---first_name`) and continues through the close tag `...`. A data section has no limit to the number of data sets it may contain (the above has three data sets). Notice that we have an open tag for each data set, but _only one close tag_ for the whole data set.

- The content is everything else (i.e. the text above and below the data.

The MoreData plugin can access the data and content independently. Let's first capture the data: 
    
## SETTING THE VARIABLES IN YOUR TEMPLATES ##

Place this in your template code to store and/or output the data. For arrays and hashes, you will definitely want to capture the data in an MT variable. For a simple string variable, setting an intermediate MT variable is unnecessary.

Here we set the variables:

    <mt:MoreData moredata="first_name","array" setvar="first_name_a">
    <mt:MoreData moredata="last_name","hash" setvar="last_name_h">
    <mt:MoreData moredata="say_yes","string" setvar="say_yes_s">

`mt:MoreData` is the tag containing your data strings. `moredata` is the modifier which detects and parses the data. The modifier arguments `"first_name","array"` indicates which data section we wish to capture, and the data type, respectively.

If no format (array, hash, or string) is given, the blog default is used. The default default is "string". (The default format and the open and close tags are configurable in the plugin settings.) So for a string variable, the following template code will output the string:

    <mt:MoreData moredata="say_yes"> # outputs "Why, certainly!" 


You may want to review the [Movable Type](http://www.movabletype.org/documentation/appendices/tags/var.html) or [Melody](https://github.com/openmelody/melody/wiki/tags-var) documentation of the `mt:Var` tag with arrays and hashes.  Once we have set the array, hash, or string variables, using them is purely Movable Type syntax. Therefore the following examples are just pure Movable Type syntax which I include here as a review. 

## USING THE VARIABLES ##

Let's use the variables that we set above (in the edit entry or edit page form) from within or templates. 

### Array via loop:

    <mt:Loop name="first_name_a">
        <mt:Var name="__value__"><br /> 
    </mt:Loop>

produces:

    Moe
    Larry
    Curly

### Array by index:

    <mt:Var name="first_name_a[2]"> # gives Larry

### Hash by loop:

    <mt:Loop name="last_name_h">
      <mt:Var name="__key__"> <mt:Var name="__value__"><br /> # gives Moe Howard, Curly Howard, Lary Fine
    </mt:Loop>                                           # hash loops have their own special order

produces (in random order as perl hashes do):

    Moe Howard
    Curly Howard
    Larry Fine

### Hash by key:

    <mt:Var name="last_name_h{Moe}">  # gives Howard

The array index or hash key can be a variable. Here is a slightly sophisticated example, in which I loop through an array, using the array value as the key to a different hash variable.

    <mt:Loop name="first_name_a">
        <mt:Var name="__value__" setvar="first_name">
        <mt:Var name="first_name"> says, "I'm Dr. <mt:Var name="last_name_h{$first_name}">!<br />
    </mt:Loop>
    <br />
    Can we help you? <mt:Var name="say_yes_s"><br />
    
produces (in precise order this time):

    Moe says, "I'm Dr. Howard"!
    Larry says, "I'm Dr. Fine"!
    Curly says, "I'm Dr. Howard"!

    Can we help you? Why, certainly!

I like using MT variables in my Templates. With the MoreData I can indulge my "variables jones".

OK now back to more MoreData features.

## COLLECTING DATA FROM MULTIPLE SOURCES INTO A SINGLE VARIABLE
As of version 0.4, multiple instances of named data strings can be collected and saved into a single MT hash, array, or string variables. For example, if your `Asset Description` fields had a MoreData field like this:

    ---locations=
    Paris = 1
    Tokyo = 1
    ...

Then you could collect all the data into a single hash variable like this:

    <mt:SetVarBlock name="asset_data">
    <mt:Assets>
        <mt:AssetDescription convert_breaks="0" moredata="__data__">
    </mt:Assets>
    </mt:SetVarBlock>

The `"__data__"` argument merely extracts the raw data strings from the text fields. The resulting tag:

    <$mt:Var name="asset_data"$>

Will contain all the data which was collected in the `mt:Assets` loop, for example:

    ---locations=
    Paris = 1
    Marseille = 1
    Bordeaux = 1
    ---locations=
    Chicago = 1
    "New York" = 1
    "SanFrancisco" = 1
    ---locations=
    Tijuana = 1
    Cozumel = 1
    "Mexico City" = 1
    ---stooges=
    Moe, Larry, Curly
    ---locations=
    Denver = 1
    Chicago = 1
    "SanFrancisco" = 1
    ---locations=
    London = 1
    Cardiff = 1
    ---locations=
    Marseille = 1
    Bordeaux = 1
    ---bears=
    Sweetness, Refrigerator, "Iron Mike"
    ...


Note that other data can be mixed in. That's OK. We want to extract only the locations data:

    <mt:Var name="asset_data" moredata="locations","hash" setvar="locations_h">

Then print a list of all (unique) locations associated with your assets like this:

    <ul>
    <mt:Loop name="locations_h">
        <li>
            <mt:Var name=__key__">
        </li>
    </mt:Loop>
    </ul>

Note that hash keys must be unique, so duplicate locations are not listed twice. The output would look something like this:

- Cozumel
- Marseille
- SanFrancisco
- Tijuana
- London
- Cardiff
- Mexico City
- Denver
- Paris
- Bordeaux
- Chicago
- New York

Pretty neat.

## RETRIEVING THE TAG CONTENT WITHOUT THE DATA ##
The content can be output separately with the `__content__` key:

    My content is: <mt:EntryExcerpt moredata="__content__">
    
Will output 

    Here is my excerpt which I can output without the data. And here is a continuation of the excerpt.

So your text fields can do double-duty (or triple, quadruple, etc).

## BLOG-WIDE PLUGIN CONFIGURATION ##

The plugin takes five blog-wide settings:

- `opentag` should be a unique string which opens a data section, and is required for each data identifier.
- `closetag` is required at the end of the whole dataset. Optionally it can close each data section.
- `datasep` is a character that joins items in an array. Default is a comma ",".
- `hashsep` is a character that joins keys from values. Efault is an equal sign "=".
- `format` is the default format, used when a second argument to the `moredata` modifier is not given.

These defaults are listed below the MoreData custom field form for your convenience.

## VARIABLE SCOPE ##

The data is naturally scoped to whichever field that it is placed in. So data placed in the `MoreData` field or an `EntryExcerpt` field, is scoped to an entry. You could as well place data in a `CategoryDescription` field, and therefore your data is scoped to that Category. The `MoreDataBlog` field is accessible within the plugin settings, and provides a convenient place to store blog-scoped data.

## FORMATTING THE DATA (aka the damned details) ##

Each data section begins with an identifier, followed immediately by the data identifier and an equals sign:

    ---my_data=
    

Each named dataset must be terminated by another named dataset, or a closetag if it is the last, or by the end of the file:

    ---first=
    one, two, three
    ---second=
    snow = white
    ruby = red
    ...
    
You can omit the close tag if the data is at the end with no subsequent content.
  
Everything between the first `opentag` and the `closetag` (or eof) is considered data.

You can put your data block in the middle of the content (but then don't forget the close tag).

Hash key-value pairs should be put on their own line (separated by a line return). Blank lines between sets of key-value pairs are ignored. The following syntax is acceptable:

    ---first= one, two, three
    ---second= snow = white
    ruby = red
    ...

In other words, array items are separated by a comma (or whatever your default setting is), and keys are separated by their values by a colon ":" (or whatever you set in plugin settings), but each key-value pair in a named hash group must be separated by a line return.

The data is processed with Text::CSV allowing whitespace and double quoted strings.

There should be no extra whitespace between the open tag, your data identifier, and the `=` sign. So for example with the default open tag, you should always do this `---my tag=`. In other words your data identifier can only have internal spaces.

## CHOOSING TAGS AND SEPARATORS ##
You can configure the open and close tags and the data and hash separator strings. The data separator and hash separator strings can be the same if you wish.

If your separator character appears in your data, be sure to add quotes around the string (see [Text::CSV documentation](http://search.cpan.org/~makamaka/Text-CSV-1.21/lib/Text/CSV.pm)). For example, this array works:

---names=
"Payton, Walter", "Singletary, Michael", "Perry, William"
...

Avoid having your open tags appearing in the preceding content or your close tags appearing in subsequent content.

You data identifiers can have spaces like `---first name=` or be empty `---=`. In the former you would use `moredata="first name"`. The latter would be `moredata=""`. But don't use the bareword modifier `moredata` without at least the name argument, even if it is the empty string.

## DEPENDENCIES ##
Requires the Text::CSV module. As of version 0.60, the `Text::CSV` module is bundled into extlib. Of course you will enjoy a considerable speed increase if your system has the Text::CSV_XS module installed.

## CHANGELOG ##
- version 0.8  Compatible with MT5.
- version 0.7  MoreData no longer breaks the Custom Fields plugin.
- version 0.6  Add the MoreDataBlog tag and respective plugin configuration field. Also bundled Text::CSV in extlib.
- version 0.5: Add the MoreData custom field and improve documentation and examples.
- version 0.4: Collects multiple instances of same-named data sets from within a larger dataset. Also ignores blank lines in a hash datastring.

## CONTRIBUTORS ##
[naoaki onozaki](https://github.com/naoaki011) wrote the L10N module and Japanese translation.

##  RELATED PLUGINS ##
The venerable and awesome [Key Values plugin by Brad Choate](http://bradchoate.com/weblog/2002/07/27/keyvalues) was my inspiration for the MoreData plugin.

## SUPPORT ##
Please send questions, comments, or criticisms to rick@hiranyaloka.com. Checkout the [moredata plugin home page](http://hiranyaloka.com/website_design_encinitas/software/moredata-plugin-for-movable-type.html)

## BUNDLED MODULES ##
[Text::CSV](http://search.cpan.org/perldoc?Text::CSV)

Copyright (C) 1997 Alan Citterman. All rights reserved. Copyright (C) 2007-2009 Makamaka Hannyaharamitu.

Text::CSV_PP:

Copyright (C) 2005-2010 Makamaka Hannyaharamitu.

## MOREDATA COPYRIGHT AND LICENSE ##

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

This software is offered "as is" with no warranty.

MoreData is Copyright 2011, Rick Bychowski, rick@hiranyaloka.com.
All rights reserved.
