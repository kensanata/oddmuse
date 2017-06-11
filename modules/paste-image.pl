#! /usr/bin/perl
# Copyright (C) 2017  Alex Schroeder <alex@gnu.org>

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use v5.10;

AddModuleDescription('paste-image.pl', 'Paste Files to Upload');

our (@MyInitVariables, %IndexHash, $ScriptName, $HtmlHeaders);

push(@MyInitVariables, \&PasteImageScript);

sub PasteImageScript {
  my $id = GetId();
  return unless $id;
  AllPagesList(); # init %IndexHash
  OpenPage($id);
  my $username = GetParam('username', '');
  my $n = 1;
  my $pic;
  $n++ while ($IndexHash{$pic = "Image_${n}_for_$id"});
  my $title = NormalToFree($pic);
  if ($HtmlHeaders !~ /PasteImage/) {
    $HtmlHeaders .= << "EOT";
<script type="text/javascript">
var PasteImage = {

  init: function() {
    let e = document.getElementById('text') || document.getElementById('aftertext');
    if (e)
      e.addEventListener('paste', PasteImage.handler);
  },

  handler: function(e) {
    // Chrome
    if (e.clipboardData) {
      let items = e.clipboardData.items;
      for (var i = 0; i < items.length; i++) {
	if (items[i].type.indexOf("image") !== -1) {
          let blob = items[i].getAsFile();
          let reader = new window.FileReader();
          reader.onloadend = function() {
            PasteImage.process(reader.result);
          }
          reader.readAsDataURL(blob);
        }
      }
    }
  },

  process: function(dataUrl) {
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "$ScriptName", true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        if (xhr.status == 200) {
          let e = document.getElementById('text') || document.getElementById('aftertext');
          e.value += '[[image:$title]]';
        } else {
          let re = /<h1>(.*)<\\/h1>/g;
          let match = re.exec(xhr.responseText);
          alert(match[1]);
        }
      }
    }

    let mimeType = dataUrl.split(',')[0].split(':')[1].split(';')[0];
    let content = encodeURIComponent(dataUrl.split(',')[1]);
    let params = "title=" + encodeURIComponent("$pic");
    params += "&summary=" + encodeURIComponent("$title");
    params += "&username=" + encodeURIComponent("$username");
    params += "&recent_edit=on";
    params += "&question=1";
    params += "&text=#FILE " + mimeType + "%0A" + content;
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhr.send(params);
  },
};
window.addEventListener('load', PasteImage.init);
</script>
EOT
  }
}
