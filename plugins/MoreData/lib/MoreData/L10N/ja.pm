# $Id$

package MoreData::L10N::ja;

use strict;
use base 'MoreData::L10N::en_us';
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (
    'Extract custom data structures from fields.' => 'フィールドから、定義した構造でデータを読み出します。',
    'Rick Bychowski' => 'Rick Bychowski',
    'Open Tag' => '開始タグ',
    'Close Tag' => '終了タグ',
    'Data Separator' => 'データ区切り文字',
    'Hash Separator' => 'ハッシュ区切り文字',
    'Default Data Format' => 'デフォルトデータ形式',
    'A tag which signals the start of your data.' => 'データの開始を表すタグ。',
    'A tag which signals the end of your data - not required if data is always below all content.'
      => 'データの終了を表すタグ - コンテンツの最後までを対象とする場合は必要ありません。',
    'A character to join your data.' => 'データを連結する区切り文字列。',
    'A character to join keys with values.' => 'キーを連結する区切り文字列。',
    'Choose a default data format (currently only csv).' => 'デフォルトのデータ形式を選択します (現在はCSVのみです)。',
    'hash' => 'ハッシュ',
    'array' => '配列',
    'string' => '文字列',
    'DataTable' => 'DataTable',
    'JSON' => 'JSON',
    'XML' => 'XML',
    'Perl' => 'Perl',
);

1;
