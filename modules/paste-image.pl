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

our (@MyInitVariables, $ScriptName, $HtmlHeaders, $MaxPost, $CommentsPattern,
     $QuestionaskerSecretKey);

our ($PageImageOnBrowse);

$PageImageOnBrowse = 0;

push(@MyInitVariables, \&PasteImageScript);

# Resampling based on the following:
# https://stackoverflow.com/a/19223362/534893
# https://github.com/viliusle/Hermite-resize

sub PasteImageScript {
  my $id = GetId();
  return unless $id;
  OpenPage($id);
  my $username = GetParam('username', '');
  my $templatePage = "Image_{n}_for_$id";
  my $templateText = "Image {n}";
  my $question = $QuestionaskerSecretKey || 'question';
  if ((GetParam('action', 'browse') eq 'edit'
       or $CommentsPattern and $id =~ /$CommentsPattern/
       or $PageImageOnBrowse and GetParam('action', 'browse') eq 'browse')
      and $HtmlHeaders !~ /PasteImage/) {
    $HtmlHeaders .= << "EOT";
<script type="text/javascript">
if (!HTMLTextAreaElement.prototype.insertAtCaret) {
  HTMLTextAreaElement.prototype.insertAtPoint = function (text) {
    text = text || '';
    if (this.selectionStart || this.selectionStart === 0) {
      // Others
      var startPos = this.selectionStart;
      var endPos = this.selectionEnd;
      this.value = this.value.substring(0, startPos) +
	text +
	this.value.substring(endPos, this.value.length);
      this.selectionStart = startPos + text.length;
      this.selectionEnd = startPos + text.length;
    } else {
      this.value += text;
    }
  };
};

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
            let dataUrl = reader.result;
            let n = 1;
            while (n++ < 4 && $MaxPost > 0 && dataUrl.length > $MaxPost)
              dataUrl = PasteImage.shrink(dataUrl);
            PasteImage.process(dataUrl, "$templatePage", "$templateText", 1);
          }
          reader.readAsDataURL(blob);
        }
      }
    }
  },

  shrink: function(dataUrl) {
    let image = new Image;
    image.src = dataUrl;

    let canvas = document.createElement("canvas");
    canvas.width = image.width;
    canvas.height = image.height;

    let ctx = canvas.getContext("2d");
    ctx.drawImage(image, 0, 0);

    let width_source = canvas.width;
    let height_source = canvas.height;
    let width = Math.round(width_source * 0.8);
    let height = Math.round(height_source * 0.8);

    let ratio_w = width_source / width;
    let ratio_h = height_source / height;
    let ratio_w_half = Math.ceil(ratio_w / 2);
    let ratio_h_half = Math.ceil(ratio_h / 2);

    let img = ctx.getImageData(0, 0, width_source, height_source);
    let img2 = ctx.createImageData(width, height);
    let data = img.data;
    let data2 = img2.data;

    for (let j = 0; j < height; j++) {
      for (let i = 0; i < width; i++) {
        let x2 = (i + j * width) * 4;
        let weight = 0;
        let weights = 0;
        let weights_alpha = 0;
        let gx_r = 0;
        let gx_g = 0;
        let gx_b = 0;
        let gx_a = 0;
        let center_y = (j + 0.5) * ratio_h;
        let yy_start = Math.floor(j * ratio_h);
        let yy_stop = Math.ceil((j + 1) * ratio_h);
        for (let yy = yy_start; yy < yy_stop; yy++) {
          let dy = Math.abs(center_y - (yy + 0.5)) / ratio_h_half;
          let center_x = (i + 0.5) * ratio_w;
          let w0 = dy * dy; //pre-calc part of w
          let xx_start = Math.floor(i * ratio_w);
          let xx_stop = Math.ceil((i + 1) * ratio_w);
          for (let xx = xx_start; xx < xx_stop; xx++) {
            let dx = Math.abs(center_x - (xx + 0.5)) / ratio_w_half;
            let w = Math.sqrt(w0 + dx * dx);
            if (w >= 1) {
              //pixel too far
              continue;
            }
            //hermite filter
            weight = 2 * w * w * w - 3 * w * w + 1;
            let pos_x = 4 * (xx + yy * width_source);
            //alpha
            gx_a += weight * data[pos_x + 3];
            weights_alpha += weight;
            //colors
            if (data[pos_x + 3] < 255)
              weight = weight * data[pos_x + 3] / 250;
            gx_r += weight * data[pos_x];
            gx_g += weight * data[pos_x + 1];
            gx_b += weight * data[pos_x + 2];
            weights += weight;
          }
        }
        data2[x2] = gx_r / weights;
        data2[x2 + 1] = gx_g / weights;
        data2[x2 + 2] = gx_b / weights;
        data2[x2 + 3] = gx_a / weights_alpha;
      }
    }
    canvas.width = width;
    canvas.height = height;
    ctx.putImageData(img2, 0, 0);
    let png = canvas.toDataURL();
    let jpg = canvas.toDataURL('image/jpeg');
    return png <= jpg ? png : jpg;
  },

  process: function(dataUrl, templatePage, templateText, n) {
    let name = templatePage.replace('{n}', n);
    let text = templateText.replace('{n}', n);
    let xhr = new XMLHttpRequest();
    xhr.open("HEAD", "$ScriptName/" + name, true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        if (xhr.status == 200) {
          PasteImage.process(dataUrl, templatePage, templateText, n+1);
        } else if (xhr.status == 404) {
          PasteImage.post(dataUrl, name, text);
        } else {
          let re = /<h1>(.*)<\\/h1>/g;
          let match = re.exec(xhr.responseText);
          alert(match[1]);
        }
      }
    };
    xhr.send(null);
  },

  post: function(dataUrl, name, text) {
    let xhr = new XMLHttpRequest();
    xhr.open("POST", "$ScriptName", true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        if (xhr.status == 200) {
          let e = document.getElementById('text') || document.getElementById('aftertext');
          e.insertAtPoint("[[image:" + name + "|" + text + "]]");
        } else {
          let re = /<h1>(.*)<\\/h1>/g;
          let match = re.exec(xhr.responseText);
          alert(match[1]);
        }
      }
    }

    let mimeType = dataUrl.split(',')[0].split(':')[1].split(';')[0];
    let content = encodeURIComponent(dataUrl.split(',')[1]);
    let params = "title=" + encodeURIComponent(name);
    params += "&summary=" + encodeURIComponent(name);
    params += "&username=" + encodeURIComponent("$username");
    params += "&recent_edit=on";
    params += "&$question=1";
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
