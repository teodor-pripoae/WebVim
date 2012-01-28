#! /bin/bash
git checkout master
make build
coffeedoc js/*.coffee
tmp_dir=$(mktemp -d)
mkdir $tmp_dir/js 
mkdir $tmp_dir/js/templates
mkdir $tmp_dir/css
cp js/*.js $tmp_dir/js/
cp js/templates/*.js $tmp_dir/js/templates/
cp css/*.css $tmp_dir/css
cp index.html $tmp_dir
cp -r docs $tmp_dir
git checkout  gh-pages
cp -r $tmp_dir/* ./

